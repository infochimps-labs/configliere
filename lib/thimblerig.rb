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


