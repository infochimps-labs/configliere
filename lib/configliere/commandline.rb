module Configliere

  #
  # Command line tool to manage param info
  #
  # @example
  #   Settings.use :commandline
  #
  module Commandline
    attr_accessor :rest
    attr_accessor :description
    attr_reader   :unknown_argvs

    # Processing to reconcile all options
    #
    # Configliere::Commandline's resolve!:
    #
    # * processes all commandline params
    # * if the --help param was given, prints out a usage statement describing all #define'd params and exits
    # * calls up the resolve! chain.
    #
    def resolve!
      process_argv!
      if self[:help]
        dump_help
        exit(2)
      end
      super()
      self
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
      @unknown_argvs = []
      until args.empty? do
        arg = args.shift
        case
        # end of options parsing
        when arg == '--'
          self.rest += args
          break
        # --param=val or --param
        when arg =~ /\A--([\w\-\.]+)(?:=(.*))?\z/
          param, val = [$1, $2]
          warn "Configliere uses _underscores not dashes for params" if param.include?('-')
          @unknown_argvs << param.to_sym if (not has_definition?(param))
          self[param] = parse_value(val)
        # -abc
        when arg =~ /\A-(\w\w+)\z/
          $1.each_char do |flag|
            param = find_param_for_flag(flag)
            unless param then @unknown_argvs << flag ; next ; end
            self[param] = true
          end
        # -a val
        when arg =~ /\A-(\w)\z/
          flag = find_param_for_flag($1)
          unless flag then @unknown_argvs << flag ; next ; end
          if (not args.empty?) && (args.first !~ /\A-/)
            val = args.shift
          else
            val = nil
          end
          self[flag] = parse_value(val)
        # -a=val
        when arg =~ /\A-(\w)=(.*)\z/
          flag, val = [find_param_for_flag($1), $2]
          unless flag then @unknown_argvs << flag ; next ; end
          self[flag] = parse_value(val)
        else
          self.rest << arg
        end
      end
      @unknown_argvs.uniq!
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
      return unless self[setting_name]
      flag_name ||= setting_name
      (self[setting_name] == true ? "--#{flag_name.to_s.gsub(/_/,"-")}" : "--#{flag_name.to_s.gsub(/_/,"-")}=#{self[setting_name]}" )
    end

    # dashed_flag_for each given setting that has a value
    def dashed_flags *settings_and_names
      settings_and_names.map{|args| dashed_flag_for(*args) }.compact
    end

    # ===========================================================================
    #
    # Commandline help
    #

    # Write the help string to stderr
    def dump_help str=nil
      warn help(str)+"\n"
    end

    # The contents of the help message.
    # Lists the usage as well as any defined parameters and environment variables
    def help str=nil
      buf = []
      buf << usage
      buf << "\n"+@description if @description
      buf << param_lines
      buf << commands_help if respond_to?(:commands_help)
      buf << "\n\n"+str if str
      buf.flatten.compact.join("\n")+"\n"
    end

    # Usage line
    def usage
      %Q{usage: #{raw_script_name} [...--param=val...]}
    end

    # the script basename, for recycling into help messages
    def raw_script_name
      File.basename($0)
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

  protected

    # handle --param (true), --param='' (set as ++nil++), --param=hi ('hi')
    def parse_value val
      case
      when val == nil then true  # --flag    option on its own means 'set that option'
      when val == '' then nil    # --flag='' the explicit empty string means nil
      else val                   # else just return the value
      end
    end

    # Retrieve the first param defined with the given flag.
    def find_param_for_flag(flag)
      params_with(:flag).each do |param_name, param_flag|
        return param_name if flag.to_s == param_flag.to_s
      end
      nil
    end

    def param_lines
      pdefs = definitions.reject{|name, definition| definition[:internal] }
      return if pdefs.empty?
      buf = ["\nParams:"]
      width     = find_width(pdefs.keys)
      has_flags = (not params_with(:flag).empty?)
      pdefs.sort_by{|pn, pd| pn.to_s }.each do |name, definition|
        buf << param_line(name, definition, width, has_flags)
      end
      buf
    end

    # pretty-print a param
    def param_line(name, definition, width, has_flags)
      desc = definition_of(name, :description).to_s.strip
      buf = ['  ']
      buf << (definition[:flag] ? "-#{definition[:flag]}," : "   ") if has_flags
      buf << sprintf("--%-#{width}s", param_with_type(name))
      buf << (desc.empty? ? name : desc)
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
      str  = param.to_s
      type = definition_of(param, :type)
      case type
      when :boolean then str += ''
      when nil      then str += '=String'
      else               str += "=#{type}"
      end
      str
    end

  end

  Param.on_use(:commandline) do
    extend Configliere::Commandline
  end
end
