require 'yaml'
require 'fileutils'
module Configliere
  # Where to load params given only a symbol
  DEFAULT_CONFIG_FILE = ENV['HOME'].to_s+'/.configliere.yaml' unless defined?(DEFAULT_CONFIG_FILE)
  # Where to load params given a bare filename
  DEFAULT_CONFIG_DIR  = ENV['HOME'].to_s+'/.configliere'      unless defined?(DEFAULT_CONFIG_DIR)

  #
  # ConfigFile -- load configuration from a simple YAML file
  #
  module ConfigFile
    # Load params from disk.
    # * file is in YAML format, as a hash of handle => param_hash pairs
    # * filename defaults to Configliere::DEFAULT_CONFIG_FILE (~/.configliere, probably)
    #
    # @option [String] :env
    #   If an :env option is given, only the indicated subhash is merged. This
    #   lets you for example specify production / environment / test settings
    #
    # @returns [Configliere::Params] the Settings object
    #
    # @example
    #     # Read from config/apey_eye.yaml and use settings appropriate for development/staging/production
    #     Settings.read(root_path('config/apey_eye.yaml'), :env => (ENV['RACK_ENV'] || 'production'))
    #
    def read handle, options={}
      filename = filename_for_handle(handle)
      begin
        params = YAML.load(File.open(filename)) || {}
      rescue Errno::ENOENT => e
        warn "Loading empty configliere settings file #{filename}"
        params = {}
      end
      params = params[handle] if handle.is_a?(Symbol)
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
    def save! handle
      filename = filename_for_handle(handle)
      if handle.is_a?(Symbol)
        ConfigFile.merge_into_yaml_file filename, handle, self.export.to_hash
      else
        ConfigFile.write_yaml_file filename, self.export.to_hash
      end
    end

  protected

    def self.write_yaml_file filename, hsh
      FileUtils.mkdir_p(File.dirname(filename))
      File.open(filename, 'w'){|f| f << YAML.dump(hsh) }
    end

    def self.merge_into_yaml_file filename, handle, params
      begin
        all_settings = YAML.load(File.open(filename)) || {}
      rescue Errno::ENOENT => e;
        all_settings = {}
      end
      all_settings[handle] = params
      write_yaml_file filename, all_settings
    end

    def filename_for_handle handle
      case
      when handle.is_a?(Symbol)      then Configliere::DEFAULT_CONFIG_FILE
      when handle.to_s.include?('/') then File.expand_path(handle)
      else                                File.join(Configliere::DEFAULT_CONFIG_DIR, handle)
      end
    end

  end

  Param.class_eval do
    # include read / save operations
    include ConfigFile
  end
end
