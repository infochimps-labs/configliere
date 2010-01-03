require 'openssl'
require 'digest/sha1'
require 'yaml'
require 'cgi'

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
  def self.load thimble_key, options={}
    options = options.dup
    handle = options.delete(:handle) || File.basename($0).gsub(/\.[^\.]*$/,"").to_sym
    store  = ThimbleStore.new(options.delete(:filename))
    store.get(handle, thimble_key)
  end
  def self.save thimble_key, hsh={}
    hsh = hsh.dup
    handle = hsh.delete(:handle) || File.basename($0).gsub(/\.[^\.]*$/,"").to_sym
    store = ThimbleStore.new(hsh.delete(:filename))
    store.put!(handle, Thimblerig::Thimble.new(thimble_key, hsh))
  end
end
