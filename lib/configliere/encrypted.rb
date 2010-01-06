Configliere.use :param_store, :define, :crypter

module Configliere
  module EncryptedParam
    # The password used in encrypting params during serialization
    attr_accessor :encrypt_pass

  protected

    # @example
    #   Settings.defaults :username=>"mysql_username", :password=>"mysql_password"
    #   Settings.define :password, :encrypted => true
    #   Settings.exportable
    #     #=> {:username => 'mysql_username', :password=>"\345?r`\222\021"\210\312\331\256\356\351\037\367\326" }
    def export
      hsh = super()
      encrypted_params.each do |param|
        hsh.deep_set(param, encrypted_get(param))
      end
      hsh
    end

    def resolve!
      begin ; super() ; rescue NoMethodError ; nil ; end
      resolve_encrypted!
      self
    end

    # import values, decrypting all params marked as encrypted
    def resolve_encrypted!
      self.encrypt_pass = self.delete(:encrypt_pass) if self[:encrypt_pass]
      encrypted_params.each do |param|
        self[param] = self.decrypted(self[param])
      end
    end

    # list of all params to encrypt on serialization
    def encrypted_params
      params_with(:encrypted)
    end

    def decrypted val
      return val if val.to_s == ''
      Configliere::Crypter.decrypt(val, encrypt_pass)
    end

    def encrypted_get(param)
      val = self[param] or return
      Configliere::Crypter.encrypt(val, encrypt_pass)
    end
  end

  class Param
    include EncryptedParam
  end
end

