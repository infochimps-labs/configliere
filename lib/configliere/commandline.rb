# Configliere.use :define
module Configliere

  #
  # Command line tool to manage param info
  #
  module Commandline
    attr_accessor :rest
    alias_method :argv, :rest

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
      dump_help_if_requested
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
      when val == nil then true            # --flag    option on its own means 'set that option'
      when val == '' then nil             # --flag='' the explicit empty string means nil      
      else val                             # else just return the value
      end
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

    # Retreive the first param defined with the given flag.
    def param_with_flag flag
      params_with(:flag).each do |param|
        return param if param_definitions[param][:flag].to_s == flag.to_s
      end
      raise Configliere::Error.new("Unknown option: -#{flag}") if complain_about_bad_flags?
    end

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

    # Complain about bad flags?
    def complain_about_bad_flags?
      @complain_about_bad_flags
    end

    # Force this params object to complain about bad (single-letter)
    # flags on the command-line.
    def complain_about_bad_flags!
      @complain_about_bad_flags = true
    end

    # Return the params for which a line should be printed giving
    # their usage.
    def params_with_command_line_help
      descriptions.reject{ |param, desc| param_definitions[param][:no_command_line_help] }.sort_by{ |param, desc| param.to_s }
    end

    # Help on the flags used.
    def flags_help
      help = ["\nParams"]
      help += params_with_command_line_help.map do |param, desc|
        if flag = param_definitions[param][:flag]
          "  -%s, --%-21s %s" % [flag.to_s, param.to_s, desc]
        else
          "  --%-25s %s" % [param.to_s + ':', desc]
        end
      end
    end

    # Return the params for which a line should be printing giving
    # their dependence on environment variables.
    def params_with_env_help
      definitions_for(:env_var).reject { |param, desc| param_definitions[param][:no_help] || param_definitions[param][:no_env_help] }
    end

    # Help on environment variables.
    def env_var_help
      return if params_with_env_help.empty?
      [ "\nEnvironment Variables can be used to set:"] + params_with_env_help.map{ |param, env| "  %-27s %s"%[env.to_s, param]}
    end

    # Output the help message to $stderr, along with an optional extra message appended.
    def dump_basic_help extra_msg=nil
      $stderr.puts [:flags_help, :env_var_help].map { |help| send(help) }.flatten.compact.join("\n") if respond_to?(:descriptions)
      $stderr.puts "\n\n"+extra_msg unless extra_msg.blank?
      $stderr.puts ''
    end

    def dump_help str=nil
      dump_basic_help
      dump_command_help if respond_to?(:dump_command_help)
      puts str if str
    end
      
    def raw_script_name
      File.basename($0)
    end

    # Usage line
    def usage
      %Q{usage: #{raw_script_name} [...--param=val...]}
    end

  protected

    # Ouput the help string if requested
    def dump_help_if_requested
      return unless self[:help]
      $stderr.puts usage
      dump_help
      exit
    end
  end

  Param.class_eval do
    # include read / save operations
    include Commandline
  end
end
