module Configliere
  DEFAULT_FILENAME = ENV['HOME']+'/.configliere' unless defined?(DEFAULT_FILENAME)
  class ParamStore
    attr_accessor :filename
    # initialize with the filename to load from. Defaults to ParamStore::DEFAULT_FILENAME (~/.configliere, probably)
    def initialize filename=nil
      self.filename = filename || Configliere::DEFAULT_FILENAME
      load!
    end

    # Load params from disk.
    # * file is in YAML format, as a hash of handle => param_hash pairs
    # * filename defaults to ParamStore::DEFAULT_FILENAME (~/.configliere, probably)
    def load!
      begin
        @params = YAML.load_file(filename) || {}
      rescue
        warn "Creating new configliere password store in #{filename}"
        @params = { }
      end
    end

    # save to disk.
    # * file is in YAML format, as a hash of handle => param_hash pairs
    # * filename defaults to ParamStore::DEFAULT_FILENAME (~/.configliere, probably)
    def save!
      File.open(filename, 'w'){|f| f << YAML.dump(@params) }
    end

    # retrieve the given param
    def get handle, decrypt_pass
      contents = @params[handle] || {}
      Param.new decrypt_pass, contents
    end

    # delete the given param from store
    def delete! handle, decrypt_pass
      check_pass(handle, decrypt_pass) if decrypt_pass
      @params.delete(handle)
      save!
    end

    # adds the param to this store
    def put handle, param
      @params[handle] = param.to_encrypted
    end
    # add the param to this store and save the store to disk
    def put!(*args) put *args ; save! end
    # adds the param to this store in unencrypted form and save the store to disk
    def put_decrypted! handle, param
      @params[handle] = param.to_decrypted
      save!
    end

    # load the param, encrypt it, and save to disk
    def fix! handle, decrypt_pass
      put handle, get(handle, decrypt_pass)
      save!
    end

    # checks if store includes the named param
    def include? handle
      @params.include?(handle)
    end

    # List handles of each param in the store.
    def handles
      @params.keys
    end

    # checks password against param
    def check_pass handle, decrypt_pass
      get handle, decrypt_pass
    end
  end
end
