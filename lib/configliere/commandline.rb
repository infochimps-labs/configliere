# Configliere.use :define
module Configliere

  #
  # Command line tool to manage param info
  #
  module Commandline
    attr_accessor :rest
    alias_method :argv, :rest
    attr_accessor :description

    # Processing to reconcile all options
    #
    # Configliere::Commandline's resolve!:
    # * processes all commandline params
    # * if the --help param was given, prints out a usage statement (using
    #   any +:description+ set with #define) and then exits
    # * lastly, calls the next method in the resolve! chain.
    #
    def resolve!
      process_argv!
      if self[:help] then dump_help ; exit ; end
      super()
    end

    #
    # Parse the command-line args into the params hash.
    #
    # '--happy_flag'   produces :happy_flag => true in the params hash
    # '--foo=foo_val'  produces :foo => 'foo_val' in the params hash.
    # '--'             Stop parsing; all remaining args are piled into :rest
    #
    # self.rest        contains all arguments that don't start with a '--'
    #                  and all args following the '--' sentinel if any.
    #
    def process_argv!
      args = ARGV.dup
      self.rest = []
      until args.empty? do
        arg = args.shift
        case
        # end of options parsing
        when arg == '--'
          self.rest += args
          break
        # --param=val
        when arg =~ /\A--([\w\-\.]+)(?:=(.*))?\z/
          param, val = [$1, $2]
          param.gsub!(/\-/, '.')                        # translate --scoped-flag to --scoped.flag
          param = param.to_sym unless (param =~ /\./)   # symbolize non-scoped keys
          self[param] = parse_value(val)
        # -abc
        when arg =~ /\A-(\w+)\z/
          $1.each_char do |flag|
            param = param_with_flag(flag)
            self[param] = true if param
          end
        # -a=val
        # when arg =~ /\A-(\w)=(.*)\z/
        #   param, val = param_with_flag($1), $2
        #   self[param] = parse_value(val) if param
        else
          self.rest << arg
        end
      end
    end

    def parse_value val
      case
      when val == nil then true  # --flag    option on its own means 'set that option'
      when val == '' then nil    # --flag='' the explicit empty string means nil
      else val                   # else just return the value
      end
    end

    # Retrieve the first param defined with the given flag.
    def param_with_flag flag
      params_with(:flag).each do |param|
        return param if param_definitions[param][:flag].to_s == flag.to_s
      end
      raise Configliere::Error.new("Unknown option: -#{flag}")
    end

    # Configliere internal params
    def define_special_params
      Settings.define :encrypt_pass, :description => "Passphrase to extract encrypted config params.", :internal => true
    end

    # All commandline name-value params that aren't internal to configliere
    def normal_params
      reject{|param, val| param_definitions[param][:internal] }
    end

    # die with a warning
    #
    # @example
    #    Settings.define :foo, :finally => lambda{ Settings.foo.to_i < 5 or die("too much foo!") }
    #
    # @param str [String] the string to dump out before exiting
    # @param exit_code [Integer] UNIX exit code to set, default -1
    def die str, exit_code=-1
      dump_help "****\n#{str}\n****"
      exit exit_code
    end

    # Retrieve the given param, or prompt for it
    def param_or_ask attr, hint=nil
      return self[attr] if include?(attr)
      require 'highline/import'
      self[attr] = ask("#{attr}"+(hint ? " for #{hint}?" : '?'))
    end

    # ===========================================================================
    #
    # Recyle out our settings as a commandline
    #

    # Returns a flag in dashed form, suitable for recycling into the commandline
    # of an external program.
    # Can specify a specific flag name, otherwise the given setting key is used
    #
    # @example
    #   Settings.dashed_flag_for(:flux_capacitance)
    #   #=> --flux-capacitance=0.7
    #   Settings.dashed_flag_for(:screw_you, :hello_friend)
    #   #=> --hello-friend=true
    #
    def dashed_flag_for setting_name, flag_name=nil
      return unless Settings[setting_name]
      flag_name ||= setting_name
      (Settings[setting_name] == true ? "--#{flag_name.to_s.gsub(/_/,"-")}" : "--#{flag_name.to_s.gsub(/_/,"-")}=#{Settings[setting_name]}" )
    end

    def dashed_flags *settings_and_names
      settings_and_names.map{|args| dashed_flag_for(*args) }
    end

    # ===========================================================================
    #
    # Commandline help
    #

    def dump_help str=nil
      $stderr.puts help(str)
      $stderr.puts ""
      dump_command_help if respond_to?(:dump_command_help)
    end

    # The contents of the help message.
    # Lists the usage as well as any defined parameters and environment variables
    def help str=nil
      h = []
      h << usage
      h << param_lines
      h << "\n"+@description if @description
      h << "\n\n"+str if str
      h.flatten.compact.join("\n")
    end

    # Usage line
    def usage
      %Q{usage: #{raw_script_name} [...--param=val...]}
    end

    def raw_script_name
      File.basename($0)
    end

  protected

    def param_lines
      pdefs = param_definitions.reject{|name, definition| definition[:internal] }
      return if pdefs.blank?
      h = ["\nParams:"]
      width     = find_width(pdefs.keys)
      has_flags = (not params_with(:flag).blank?)
      pdefs.sort_by{|pn, pd| pn.to_s }.each do |name, definition|
        h << param_line(name, definition, width, has_flags)
      end
      h
    end

    # pretty-print a param
    def param_line(name, definition, width, has_flags)
      desc = description_for(name).to_s.strip
      buf = ['  ']
      buf << (definition[:flag] ? "-#{definition[:flag]}," : "   ") if has_flags
      buf << sprintf("--%-#{width}s", param_with_type(name))
      buf << (desc.blank? ? name : desc)
      buf << "[Default: #{definition[:default]}]"  if definition[:default]
      buf << '[Required]'                          if definition[:required]
      buf << '[Encrypted]'                         if definition[:encrypted]
      buf << "[Env Var: #{definition[:env_var]}]"  if definition[:env_var]
      buf.join(' ')
    end

    # run through the params and find the width needed to pretty-print them
    def find_width(param_names)
      [ 20,
        param_names.map{|param_name| param_with_type(param_name).length }
      ].flatten.max + 2
    end

    def param_with_type(param)
      str = param.to_s
      case type_for(param)
      when :boolean then str << ''
      when nil      then str << '=String'
      else               str << '=' + type_for(param).to_s
      end
      str
    end

  end

  Param.class_eval do
    # include read / save operations
    include Commandline
  end
end
