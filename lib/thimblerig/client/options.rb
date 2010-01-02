module Thimblerig
  class Client
    attr_accessor :options, :store, :thimble_options

    # All internal options
    INTERNAL_OPTIONS = {
      :key         => "Key for this handle. Programs must supply this key to access thimble",
      :thimblefile => "YAML file to use, #{Thimblerig::ThimbleStore::DEFAULT_FILENAME} by default",
      :hostname_in_key => "Include the hostname in the key",
      :macaddr_in_key  => "Include the ethernet MAC address in the key",
    }

  protected
    # All commandline name-value options that aren't internal to thimblerigger script
    def external_options
      options.reject{|name, val| (name.to_s[0..0]=='_') || INTERNAL_OPTIONS.include?(name) }
    end

    # die with a warning
    def die str
      warn str
      help
      exit -1
    end

    # Retrieve the given option, or prompt for it
    def option_or_ask attr
      options[attr] ||= ask("#{attr}? ")
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
      while (! args.blank?) do
        arg = args.shift
        case
        when arg == '--'
          options[:_rest] += args
          break
        when arg =~ /\A--(\w+)(?:=(.+))?\z/
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
