Configliere.use :param_store, :define, :crypter

module Configliere
  module EncryptedParam
    # The password used in encrypting params during serialization
    attr_accessor :encrypt_pass

  protected

    # @example
    #   Config.defaults :username=>"mysql_username", :password=>"mysql_password"
    #   Config.define :password, :encrypted => true
    #   Config.exportable
    #     #=> {:username => 'mysql_username', :password=>"\345?r`\222\021"\210\312\331\256\356\351\037\367\326" }
    def export
      hsh = super()
      encrypted_params.each do |param|
        hsh.deep_set(param, encrypted_get(param))
      end
      hsh
    end

    # import values, decrypting all params marked as encrypted
    def import hsh
      # done this way so we don't piss on the values in hsh
      overlay = {}
      encrypted_params.each do |param|
        overlay.deep_set(param, self.decrypted(hsh.deep_get(param)))
      end
      super hsh.deep_merge(overlay)
    end

    # list of all params to encrypt on serialization
    def encrypted_params
      params_with(:encrypted)
    end

    def decrypted val
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

