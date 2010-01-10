# Configliere.use :define
module Configliere

  #
  # Command line tool to manage param info
  #
  module Commandline
    attr_accessor :rest

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
      begin ; super() ; rescue NoMethodError ; nil ; end
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
        when arg == '--'
          self.rest += args
          break
        when arg =~ /\A--([\w\-\.]+)(?:=(.*))?\z/
          param, val = [$1, $2]
          param.gsub!(/\-/, '.')
          if    val == nil then val = true     # --flag    option on its own means 'set that option'
          elsif val == ''  then val = nil  end # --flag='' the explicit empty string means nil
          self[param] = val
        else
          self.rest << arg
        end
      end
    end

    # If your script uses the 'script_name verb [...params...]'
    # pattern, list the commands here:
    COMMANDS= {}

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
      puts help
      warn "\n****\n#{str}\n****"
      exit exit_code
    end

    # Retrieve the given param, or prompt for it
    def param_or_ask attr, hint=nil
      return self[attr] if include?(attr)
      require 'highline/import'
      self[attr] = ask("#{attr}"+(hint ? " for #{hint}?" : '?'))
    end

    def help
      help_str  = [ usage ]
      help_str += [ "\nParams:", descriptions.sort_by{|p,d| p.to_s }.map{|param, desc| "  --%-25s %s"%[param.to_s+':', desc]}.join("\n"), ] if respond_to?(:descriptions)
      # help_str += ["\nCommands", commands.map{|cmd, desc| "  %-20s %s"%[cmd.to_s+':', desc]}.join("\n")] if respond_to?(:commands)
      help_str += [ "\nEnvironment Variables can be used to set:", params_from_environment.map{|param, env| "  %-27s %s"%[env.to_s+':', param]}.join("\n"), ] if respond_to?(:params_from_environment)
      help_str.join("\n")
    end

    # Usage line
    def usage
      %Q{usage: #{File.basename($0)} [...--param=val...]}
    end

  protected

    # Ouput the help string if requested
    def dump_help_if_requested
      return unless self[:help]
      $stderr.puts help
      exit
    end
  end

  Param.class_eval do
    # include read / save operations
    include Commandline
  end
end
