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
    def read handle
      filename = filename_for_handle(handle)
      begin
        params = YAML.load(File.open(filename)) || {}
      rescue Errno::ENOENT => e
        warn "Loading empty configliere settings file #{filename}"
        params = {}
      end
      params = params[handle] if handle.is_a?(Symbol)
      deep_merge! params
    end

    # save to disk.
    # * file is in YAML format, as a hash of handle => param_hash pairs
    # * filename defaults to Configliere::DEFAULT_CONFIG_FILE (~/.configliere, probably)
    def save! handle
      filename = filename_for_handle(handle)
      if handle.is_a?(Symbol)
        ConfigFile.merge_into_yaml_file filename, handle, self.export
      else
        ConfigFile.write_yaml_file filename, self.export
      end
    end

  protected

    # form suitable for serialization to disk
    # (e.g. the encryption done in configliere/encrypted)
    def export
      super.to_hash
    end

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
      when handle.to_s.include?('/') then handle
      else                           File.join(Configliere::DEFAULT_CONFIG_DIR, handle)
      end
    end

  end

  Param.class_eval do
    # include read / save operations
    include ConfigFile
  end
end
