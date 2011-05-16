module Configliere
  # Where to load params given a bare filename
  DEFAULT_CONFIG_DIR  = ENV['HOME'].to_s+'/.configliere'      unless defined?(DEFAULT_CONFIG_DIR)

  #
  # ConfigFile -- load configuration from a simple YAML file
  #
  module ConfigFile
    # Load params from a YAML file, as a hash of handle => param_hash pairs
    #
    # @param filename [String] the file to read. If it does not contain a '/',
    #   the filename is expanded relative to Configliere::DEFAULT_CONFIG_DIR
    # @param options [Hash]
    # @option options :env [String]
    #   If an :env option is given, only the indicated subhash is merged. This
    #   lets you for example specify production / environment / test settings
    #
    # @returns [Configliere::Params] the Settings object
    #
    # @example
    #     # Read from ~/.configliere/foo.yaml
    #     Settings.read(foo.yaml)
    #
    # @example
    #     # Read from config/foo.yaml and use settings appropriate for development/staging/production
    #     Settings.read(App.root.join('config', 'environment.yaml'), :env => ENV['RACK_ENV'])
    #
    def read filename, options={}
      if filename.is_a?(Symbol) then raise Configliere::DeprecatedError, "Loading from a default config file is no longer provided" ; end
      filename = expand_filename(filename)
      begin
        params = YAML.load(File.open(filename)) || {}
      rescue Errno::ENOENT => e
        warn "Loading empty configliere settings file #{filename}"
        params = {}
      end
      # Extract the :env (production/development/etc)
      if options[:env]
        params = params[options[:env]] || {}
      end
      deep_merge! params
      self
    end

    # save to disk.
    # * file is in YAML format, as a hash of handle => param_hash pairs
    # * filename defaults to Configliere::DEFAULT_CONFIG_FILE (~/.configliere, probably)
    def save! filename
      filename = expand_filename(filename)
      hsh = self.export.to_hash
      FileUtils.mkdir_p(File.dirname(filename))
      File.open(filename, 'w'){|f| f << YAML.dump(hsh) }
    end

  protected

    def expand_filename filename
      if filename.to_s.include?('/')
        File.expand_path(filename)
      else
        File.expand_path(File.join(Configliere::DEFAULT_CONFIG_DIR, filename))
      end
    end
  end

  # ConfigFile is included by default
  Param.class_eval do
    include ConfigFile
  end
end
