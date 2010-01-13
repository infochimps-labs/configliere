require 'configliere/core_ext/sash.rb'
module Configliere
  class ParamParent < ::Sash
    def finally *args, &block
      nil #no-op
    end
    # default export method: self
    def export
      to_hash
    end
    # terminate resolution chain
    def resolve!
    end
  end

  #
  # Hash of fields to store.
  #
  # Any field name beginning with 'decrypted_' automatically creates a
  # counterpart 'encrypted_' field using the encrypt_pass.
  #
  class Param < Configliere::ParamParent

    # Initialize with the encrypt_pass and the initial contents of the hash.
    #
    # @example
    #   # Create a param for a hypothetical database with encrypt_pass "your_mom"
    #   Configliere::Param.new 'your_mom',
    #     :username=>"mysql_username", :decrypted_password=>"mysql_password"
    #
    def initialize hsh={}
      super()
      merge! hsh
    end

    #
    # Incorporates the given settings.
    # alias for deep_merge!
    # Existing values not given in the hash
    #
    # @param hsh the defaults to set.
    #
    # @example
    #    Settings.defaults :hat => :cat, :basket => :lotion, :moon => { :man => :smiling }
    #    Settings.defaults :basket => :tasket, :moon => { :cow => :smiling }
    #    Config  #=> { :hat => :cat, :basket => :tasket, :moon => { :man => :smiling, :cow => :jumping } }
    #
    def defaults hsh
      deep_merge! hsh
    end

    # Finalize and validate params
    def resolve!
      begin ; super() ; rescue NoMethodError ; nil ; end
      validate!
    end
    # Check that all defined params are valid
    def validate!
      begin ; super() ; rescue NoMethodError ; nil ; end
    end

    def []= param, val
      if param =~ /\./
        return deep_set( *( dotted_to_deep_keys(param) | [val] ))
      else
        super param, val
      end
    end

    def [] param
      if param =~ /\./
        return deep_get( *dotted_to_deep_keys(param) )
      else
        super param
      end
    end

    def delete param
      if param =~ /\./
        return deep_delete( *dotted_to_deep_keys(param) )
      else
        super param
      end
    end

    def use *args
      hsh = args.pop if args.last.is_a?(Hash)
      Configliere.use *args
      self.defaults(hsh) unless hsh.nil?
    end

    # see Configliere::ConfigBlock#finally
    def finally *args, &block
      use :config_block
      super
    end
  protected
    # turns a dotted param ('moon.cheese.type') into
    # an array of sequential keys for deep_set and deep_get
    def dotted_to_deep_keys dotted
      dotted.to_s.split(".").map{|key| key.to_sym }
    end

  end
end
