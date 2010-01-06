module Configliere
  #
  # Hash of fields to store.
  #
  # Any field name beginning with 'decrypted_' automatically creates a
  # counterpart 'encrypted_' field using the decrypt_pass.
  #
  class Param < ::Hash
    # Initialize with the decrypt_pass and the initial contents of the hash.
    #
    # @example
    #   # Create a param for a hypothetical database with decrypt_pass "your_mom"
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
    #    Config.defaults :hat => :cat, :basket => :lotion, :moon => { :man => :smiling }
    #    Config.defaults :basket => :tasket, :moon => { :cow => :smiling }
    #    Config  #=> { :hat => :cat, :basket => :tasket, :moon => { :man => :smiling, :cow => :jumping } }
    #
    def defaults hsh
      deep_merge! hsh
    end

    #
    def resolve!
    end


    def []= param, val
      if param =~ /\./
        params_and_val = param.split(".").map{|param| param.to_sym} | [val]
        return deep_set( *params_and_val )
      else
        super param, val
      end
    end

    def [] param
      if param =~ /\./
        params = param.split(".").map{|param| param.to_sym}
        return deep_get( *params )
      else
        super param
      end
    end

  #
  #   # calls back to Hash#[], but ensures that for an en/decrypted attribute its
  #   # de/encrypted counterpart is also correctly set.
  #   def []= attr, val
  #     super attr, val
  #     if    encrypted_attr?(attr)
  #       super attr_counterpart(attr), Crypter.decrypt(val, decrypt_pass)
  #     elsif decrypted_attr?(attr)
  #       super attr_counterpart(attr), Crypter.encrypt(val, decrypt_pass)
  #     end
  #     val
  #   end
  #
  #
  #   #
  #   # These methods set values and so we have to ensure
  #   # encrypted and decrypted values stay in sync.
  #   #
  #
  #   def merge! hsh
  #     super hsh
  #     hsh.each{|attr, val| self[attr] = val if special_attr?(attr) }
  #     self
  #   end
  #   def delete(attr)
  #     super(attr_counterpart(attr)) if special_attr?(attr)
  #     super(attr)
  #   end
  #   def delete_if!(*args, &block) raise "Not implemented" ; end
  #   def reject!(*args, &block)    raise "Not implemented" ; end
  #   def default=(*args, &block)   raise "Not implemented" ; end
  #   def shift()                   raise "Not implemented" ; end
    # def replace hsh
    #   super hsh
    #   sync!
    #   self
    # end
    # def rehash
    #   sync!
    # end

    # returns an actual Hash, not a Param < Hash
    def to_hash
      {}.merge! self
    end

    def to_s
      s = ["#{self.class} decrypt_pass [#{decrypt_pass.inspect}]"]
      to_decrypted.each do |attr, val|
        s << "  %-21s\t%s"%[attr.to_s+':', val.inspect]
      end
      s.join("\n")
    end

  protected

  end
end
