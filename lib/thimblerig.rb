require 'openssl'
require 'digest/sha1'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/module/delegation'
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
  def self.load handle, passpass, options={}
    options = options.dup
    store = ThimbleStore.new(options.delete(:filename))
    store.get(handle, passpass)
  end
  def self.save handle, passpass, hsh={}
    hsh = hsh.dup
    store = ThimbleStore.new(hsh.delete(:filename))
    thimble = store.get(handle, passpass)
    thimble.merge! hsh
    p [store, thimble, hsh, passpass]
    store.put!(handle, thimble)
  end
end
