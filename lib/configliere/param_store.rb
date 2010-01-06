require 'yaml'
module Configliere
  #
  # ParamStore -- load configuration from a simple YAML file
  #
  module ParamStore
    # Load params from disk.
    # * file is in YAML format, as a hash of handle => param_hash pairs
    # * filename defaults to ParamStore::DEFAULT_CONFIG_FILE (~/.configliere, probably)
    def read handle
      filename = filename_for_handle(handle)
      begin
        params = YAML.load(File.open(filename)) || {}
      rescue Errno::ENOENT => e
        warn "Loading empty configliere settings file #{filename}"
        params = {}
      end
      params = params[handle] if handle.is_a?(Symbol)
      import params
    end

    # save to disk.
    # * file is in YAML format, as a hash of handle => param_hash pairs
    # * filename defaults to ParamStore::DEFAULT_CONFIG_FILE (~/.configliere, probably)
    def save! handle
      filename = filename_for_handle(handle)
      if handle.is_a?(Symbol)
        ParamStore.merge_into_yaml_file filename, handle, self.export
      else
        ParamStore.write_yaml_file filename, self.export
      end
    end

  protected

    # form suitable for serialization to disk
    # (e.g. the encryption done in configliere/encrypted)
    def export
      to_hash
    end

    # load, undoing any modifications in serialization
    # (e.g. the decryption done in configliere/encrypted)
    def import hsh
      deep_merge! hsh
    end

    def self.write_yaml_file filename, hsh
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
      when handle.is_a?(Symbol) then Configliere::DEFAULT_CONFIG_FILE
      when handle.include?('/') then handle
      else                           File.join(Configliere::DEFAULT_CONFIG_DIR, handle)
      end
    end

  end

  Param.class_eval do
    # include read / save operations
    include ParamStore
  end
end
