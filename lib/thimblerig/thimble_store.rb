module Thimblerig
  DEFAULT_FILENAME = ENV['HOME']+'/.thimblerig' unless defined?(DEFAULT_FILENAME)
  class ThimbleStore
    attr_accessor :filename
    # initialize with the filename to load from. Defaults to ThimbleStore::DEFAULT_FILENAME (~/.thimblerig, probably)
    def initialize filename=nil
      self.filename = filename || Thimblerig::DEFAULT_FILENAME
      load!
    end

    # Load thimbles from disk.
    # * file is in YAML format, as a hash of handle => thimble_hash pairs
    # * filename defaults to ThimbleStore::DEFAULT_FILENAME (~/.thimblerig, probably)
    def load!
      begin
        @thimbles = YAML.load_file(filename) || {}
      rescue
        warn "Creating new thimblerig password store in #{filename}"
        @thimbles = { }
      end
    end

    # save to disk.
    # * file is in YAML format, as a hash of handle => thimble_hash pairs
    # * filename defaults to ThimbleStore::DEFAULT_FILENAME (~/.thimblerig, probably)
    def save!
      File.open(filename, 'w'){|f| f << YAML.dump(@thimbles) }
    end

    # retrieve the given thimble
    def get handle, thimble_key
      contents = @thimbles[handle] || {}
      Thimble.new thimble_key, contents
    end

    # delete the given thimble from store
    def delete! handle, thimble_key
      check_pass(handle, thimble_key) if thimble_key
      @thimbles.delete(handle)
      save!
    end

    # adds the thimble to this store
    def put handle, thimble
      @thimbles[handle] = thimble.to_encrypted.merge thimble.internals
    end
    # add the thimble to this store and save the store to disk
    def put!(*args) put *args ; save! end
    # adds the thimble to this store in unencrypted form and save the store to disk
    def put_decrypted! handle, thimble
      @thimbles[handle] = thimble.to_decrypted.merge thimble.internals
      save!
    end

    # load the thimble, encrypt it, and save to disk
    def fix! handle, thimble_key
      put handle, get(handle, thimble_key)
      save!
    end

    # checks if store includes the named thimble
    def include? handle
      @thimbles.include?(handle)
    end

    # List handles of each thimble in the store.
    def thimble_handles
      @thimbles.keys
    end

    # checks password against thimble
    def check_pass handle, thimble_key
      get handle, thimble_key
    end
  end
end
