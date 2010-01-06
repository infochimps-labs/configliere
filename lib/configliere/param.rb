module Configliere
  #
  # Hash of fields to store.
  #
  # Any field name beginning with 'decrypted_' automatically creates a
  # counterpart 'encrypted_' field using the encrypt_pass.
  #
  class Param < ::Hash

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
        super param.to_sym, val
      end
    end

    def [] param
      if param =~ /\./
        return deep_get( *dotted_to_deep_keys(param) )
      else
        super param.to_sym
      end
    end

    def delete param
      if param =~ /\./
        return deep_delete( *dotted_to_deep_keys(param) )
      else
        super param.to_sym
      end
    end

    # returns an actual Hash, not a Param < Hash
    def to_hash
      {}.merge! self
    end

    def use *args
      Configliere.use *args
    end

  protected
    # turns a dotted param ('moon.cheese.type') into
    # an array of sequential keys for deep_set and deep_get
    def dotted_to_deep_keys dotted
      dotted.to_s.split(".").map{|key| key.to_sym}
    end

    # simple (no-arg) method_missing callse
    def method_missing meth, *args
      if args.empty? && meth.to_s =~ /^\w+$/
        self[meth]
      elsif args.size == 1 && meth.to_s =~ /^(\w+)=$/
        self[$1] = args.first
      else super(meth, *args) end
    end
  end
end
