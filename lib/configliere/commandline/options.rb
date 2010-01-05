module Configliere
  class Client
    attr_accessor :options, :store, :param_options

    # Configliere internal options -- these have special meaning
    INTERNAL_OPTIONS = {
      :config_key          => "Key to decrypt configliere group's contents.",
      :config_file         => "YAML file to use, #{Configliere::DEFAULT_FILENAME} by default.",
    }
    # You can stuff descriptions for your own options in here, they'll be added
    # to the usage statement.
    EXTERNAL_OPTIONS = {
    }
    # If your script uses the 'script_name verb [...predicates and options...]'
    # pattern, list the commands here:
    COMMANDS= {}

    # All commandline name-value options that aren't internal to configliere
    def external_options
      options.reject{|name, val| (name.to_s[0..0]=='_') || INTERNAL_OPTIONS.include?(name) }
    end

  protected

    # die with a warning
    def die str
      puts help
      warn "\n****\n#{str}\n****"
      exit -1
    end

    # Retrieve the given option, or prompt for it
    def option_or_ask attr, hint=nil
      hint ||= handle
      return options[attr] if options.include?(attr)
      require 'highline/import'
      options[attr] = ask("#{attr} for #{hint}? ")
    end

    #
    # Parse the command-line args into the options hash.
    #
    # '--happy_flag'   produces :happy_flag => true in the options hash
    # '--foo=foo_val'  produces :foo => 'foo_val' in the options hash.
    # '--'             Stop parsing; all remaining args are piled into :rest
    #
    # options[:rest]   contains all arguments that don't start with a '--'
    #                  and all args following the '--' sentinel if any.
    #
    def process_argv!
      args = ARGV.dup
      options[:_rest] = []
      until args.empty? do
        arg = args.shift
        case
        when arg == '--'
          options[:_rest] += args
          break
        when arg =~ /\A--([\w\-]+)(?:=(.+))?\z/
          options[$1.to_sym] = $2 || true
        else
          options[:_rest] << arg
        end
      end
    end

    def process_options!
      process_argv!
      if val = options.delete(:override_hostname) then Crypter.override_hostname(val)  end
      if val = options.delete(:override_macaddr)  then Crypter.override_macaddr(val)   end
    end
  end
end
