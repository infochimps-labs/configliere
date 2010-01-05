require 'openssl'
require 'digest/sha2'
require 'yaml'

require 'configliere/crypter'
require 'configliere/param'
require 'configliere/param_store'

class Hash
  def compact!
    reject!{|attr,val| val.nil? }
  end
  def compact
    dup.compact!
  end
end

module Configliere
  #
  # Bare-bones interface to load config for a given param_name.
  #
  # @param [String] decrypt_pass the passphrase to decrypt any encrypted values
  # @option options [Symbol] :param_name the param to load. If no param_name is given, uses the basename (without extension) of the running script.
  # @option options [String] :configliere_file (Configliere::DEFAULT_FILENAME) the file to load from
  # @return [Hash] the retrieved hash
  #
  # @example
  #   config = Configliere.load 'sekret1', :param_name => :happy_script
  #
  def self.load decrypt_pass, options={}
    param_name = options[:param_name] || File.basename($0).gsub(/\.[^\.]*$/,"").to_sym
    store        = ParamStore.new(options[:configliere_file])
    store.get(param_name, decrypt_pass)
  end
  #
  # Bare-bones interface to load config for a given param_name.
  #
  # @param [String] decrypt_pass the passphrase to decrypt any encrypted values
  # @hsh   [Hash] The hash to save. Special options starting with :param_ are pulled out
  # @option hsh [Symbol] :param_name the param to load. If no param_name is given, uses the basename (without extension) of the running script.
  # @option hsh [String] :configliere_file (Configliere::DEFAULT_FILENAME) the file to load from
  #
  # @example
  #   config = { :username => 'monkeyboy', :decrypted_api_key => 'c22b5f9178342609428d6f51b2c5af4c0bde6a42' }
  #   Configliere.save 'sekret1', config.merge(:param_name => :happy_script)
  #
  def self.save decrypt_pass, hsh={}
    param_name = hsh[:param_name] || File.basename($0).gsub(/\.[^\.]*$/,"").to_sym
    store        = ParamStore.new(hsh[:configliere_file])
    param      = Param.new(decrypt_pass, hsh.reject{|k,v| k.to_s =~ /^param_/})
    store.put!(param_name, param)
  end
end
