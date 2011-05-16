require 'configliere/crypter'
module Configliere
  module EncryptedParam

    # decrypts any encrypted params
    # then calls the next step in the resolve! chain.
    def resolve!
      resolve_encrypted!
      super()
      self
    end

    # import values, decrypting all params marked as encrypted
    def resolve_encrypted!
      remove_and_adopt_encrypt_pass_param_if_any!
      encrypted_params.each do |param|
        encrypted_val = deep_delete(*encrypted_key_path(param)) or next
        self[param] = self.decrypted(encrypted_val)
      end
    end

  protected

    # @example
    #   Settings.defaults :username=>"mysql_username", :password=>"mysql_password"
    #   Settings.define :password, :encrypted => true
    #   Settings.export
    #     #=> {:username => 'mysql_username', :password=>"\345?r`\222\021"\210\312\331\256\356\351\037\367\326" }
    def export
      remove_and_adopt_encrypt_pass_param_if_any!
      hsh = super()
      encrypted_params.each do |param|
        val = hsh.deep_delete(*convert_key(param)) or next
        hsh.deep_set( *(encrypted_key_path(param) | [encrypted(val)]) )
      end
      hsh
    end

    # if :encrypted_pass was set as a param, remove it from the hash and set it as an attribute
    def remove_and_adopt_encrypt_pass_param_if_any!
      @encrypt_pass ||= self.delete(:encrypt_pass) if self[:encrypt_pass]
      @encrypt_pass ||= ENV['ENCRYPT_PASS']        if ENV['ENCRYPT_PASS']
    end

    # the chain of symbol keys for a dotted path key,
    # prefixing the last one with "encrypted_"
    #
    # @example
    #    encrypted_key_path('amazon.api.key')
    #    #=> [:amazon, :api, :encrypted_key]
    def encrypted_key_path param
      encrypted_path = Array(convert_key(param))
      encrypted_path[-1] = "encrypted_#{encrypted_path.last}".to_sym
      encrypted_path
    end

    # list of all params to encrypt on serialization
    def encrypted_params
      params_with(:encrypted).keys.select{|p| definition_of(p, :encrypted) }
    end

    def decrypted val
      return val.to_s if val.to_s.empty?
      Configliere::Crypter.decrypt(val, @encrypt_pass)
    end

    def encrypted val
      return unless val
      Configliere::Crypter.encrypt(val, @encrypt_pass)
    end
  end

  Param.on_use(:encrypted) do
    use :config_file, :define
    extend EncryptedParam
  end
end
