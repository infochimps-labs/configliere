module Thimblerig
  DEFAULT_FILENAME = ENV['HOME']+'/.thimblerig' unless defined?(DEFAULT_FILENAME)
  class ThimbleStore
    attr_accessor :filename
    # initialize with the filename to load from. Defaults to ThimbleStore::DEFAULT_FILENAME (~/.thimblerig, probably)
    def initialize filename=nil
      self.filename = filename || Thimblerig::DEFAULT_FILENAME
      load!
    end

    def load!
      begin
        @thimbles = YAML.load_file(filename) || {}
      rescue
        warn "Creating new thimblerig password store in #{filename}"
        @thimbles = { }
      end
    end

    # save to disk.
    # the file is in standard YAML format.
    def save!
      File.open(filename, 'w'){|f| f << YAML.dump(@thimbles) }
    end

    # retrieve the given thimble
    def get handle, thimble_key
      contents = @thimbles[handle] || {}
      Thimble.new thimble_key, contents
    end

    def include? handle
      @thimbles.include?(handle)
    end

    # checks password against thimble
    def check_pass handle, thimble_key
      get handle, thimble_key
    end

    # retrieve the given thimble
    def delete! handle, thimble_key
      check_pass(handle, thimble_key) if thimble_key
      @thimbles.delete(handle)
      save!
    end

    def handles
      @thimbles.keys
    end

    # adds the thimble to this store
    def put handle, thimble
      @thimbles[handle] = thimble.to_encrypted.merge thimble.internals
    end
    # add the thimble to this store and save the store to disk
    def put!(*args) put *args ; save! end
    # adds the thimble to this store
    def put_decrypted! handle, thimble
      @thimbles[handle] = thimble.to_decrypted.merge thimble.internals
      save!
    end

    # load the thimble, encrypt it, and save to disk
    def fix! handle, thimble_key
      put handle, get(handle, thimble_key)
      save!
    end
  end
end
