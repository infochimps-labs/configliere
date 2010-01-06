Configliere.use :param_store, :define, :crypter

module Configliere
  module EncryptedParam

    # @example
    #   Config.defaults :username=>"mysql_username", :password=>"mysql_password"
    #   Config.define :password, :encrypted => true
    #   Config.exportable
    #     #=> {:username => 'mysql_username', :password=>"\345?r`\222\021"\210\312\331\256\356\351\037\367\326" }
    def to_exportable
      hsh = super()
    end

    # list of all params to encrypt on serialization
    def encrypted_params
      param_definitions.keys.find_all{|param| param_definitions[param][:encrypted] }
    end

    def self.included base
      base.class_eval do
        attr_accessor :encrypt_pass
      end
    end
  end

  class Param
    include EncryptedParam
  end
end

