require 'thimblerig/client/options'
require 'logger'
module Thimblerig
  #
  # Command line tool to manage thimble info
  #
  class Client
    attr_accessor :command, :handle
    def initialize
      self.options = {}
      process_options!
      self.store = Thimblerig::ThimbleStore.new(options[:thimble_file])
    end

    # get the thimble for the given handle
    def get handle, key=nil, options=nil
      store.get(handle, key || option_or_ask(:key))
    end
  end
end
