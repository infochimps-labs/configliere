require 'openssl'
require 'digest/sha2'
require 'yaml'

require 'thimblerig/crypter'
require 'thimblerig/thimble'
require 'thimblerig/thimble_store'

class Hash
  def compact!
    reject!{|attr,val| val.nil? }
  end
  def compact
    dup.compact!
  end
end

module Thimblerig
  #
  # Bare-bones interface to load config for a given thimble_name.
  #
  # @param [String] thimble_key the passphrase to decrypt any encrypted values
  # @option options [Symbol] :thimble_name the thimble to load. If no thimble_name is given, uses the basename (without extension) of the running script.
  # @option options [String] :thimble_file (Thimblerig::DEFAULT_FILENAME) the file to load from
  # @return [Hash] the retrieved hash
  #
  # @example
  #   config = Thimblerig.load 'sekret1', :thimble_name => :happy_script
  #
  def self.load thimble_key, options={}
    thimble_name = options[:thimble_name] || File.basename($0).gsub(/\.[^\.]*$/,"").to_sym
    store        = ThimbleStore.new(options[:thimble_file])
    store.get(thimble_name, thimble_key)
  end
  #
  # Bare-bones interface to load config for a given thimble_name.
  #
  # @param [String] thimble_key the passphrase to decrypt any encrypted values
  # @option options [Symbol] :thimble_name the thimble to load. If no thimble_name is given, uses the basename (without extension) of the running script.
  # @option options [String] :thimble_file (Thimblerig::DEFAULT_FILENAME) the file to load from
  # @return [Hash] the retrieved hash
  #
  # @example
  #   config = { :username => 'monkeyboy', :decrypted_api_key => 'c22b5f9178342609428d6f51b2c5af4c0bde6a42' }
  #   Thimblerig.save 'sekret1', config.merge(:thimble_name => :happy_script)
  #
  def self.save thimble_key, hsh={}
    thimble_name = hsh[:thimble_name] || File.basename($0).gsub(/\.[^\.]*$/,"").to_sym
    store        = ThimbleStore.new(hsh[:thimble_file])
    thimble      = Thimble.new(thimble_key, hsh.reject{|k,v| k.to_s =~ /^thimble_/})
    store.put!(thimble_name, thimble)
  end
end
