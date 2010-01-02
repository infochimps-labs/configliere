require 'thimblerig/client/options'
module Thimblerig
  #
  # Command line tool to manage thimble info
  #
  class Client
    attr_accessor :command, :handle
    def initialize handle=nil
      self.handle  = handle
      self.options = {}
      process_options!
      self.store = Thimblerig::ThimbleStore.new(options[:thimble_file])
    end

    # get the thimble for the given handle
    def get handle, key=nil, options=nil
      begin
        store.get(handle, key || option_or_ask(:key, handle))
      rescue OpenSSL::Cipher::CipherError => e
        warn "Decrypt error: wrong password for #{handle}"; exit 3
      end
    end
  end
end
