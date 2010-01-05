module Configliere
  #
  # Hash of fields to store.
  #
  # Any field name beginning with 'decrypted_' automatically creates a
  # counterpart 'encrypted_' field using the decrypt_pass.
  #
  class Param < ::Hash
    attr_accessor :decrypt_pass
    # Initialize with the decrypt_pass and the initial contents of the hash.
    #
    # @example
    #   # Create a param for a hypothetical database with decrypt_pass "your_mom"
    #   Configliere::Param.new 'your_mom',
    #     :username=>"mysql_username", :decrypted_password=>"mysql_password"
    #
    def initialize decrypt_pass, hsh={}
      super()
      self.decrypt_pass = decrypt_pass
      merge! hsh
      sync!
    end

    # calls back to Hash#[], but ensures that for an en/decrypted attribute its
    # de/encrypted counterpart is also correctly set.
    def []= attr, val
      super attr, val
      if    encrypted_attr?(attr)
        super attr_counterpart(attr), Crypter.decrypt(val, decrypt_pass)
      elsif decrypted_attr?(attr)
        super attr_counterpart(attr), Crypter.encrypt(val, decrypt_pass)
      end
      val
    end

    #
    # A hash containing only regular and decrypted pairs
    #
    # Example:
    #   pp
    #   # => {:username=>"mysql_username", :decrypted_password=>"mysql_password", :encrypted_password=>"\345?r`\222\021"\210\312\331\256\356\351\037\367\326"}
    #   pp.to_decrypted
    #   # => {:username=>"mysql_username", :decrypted_password=>"mysql_password" }
    #
    def to_decrypted
      reject{|attr, val| encrypted_attr?(attr) }.to_hash
    end
    #
    # A hash containing only regular and encrypted pairs
    #
    # Example:
    #   pp
    #   # => {:username=>"mysql_username", :decrypted_password=>"mysql_password", :encrypted_password=>"\345?r`\222\021"\210\312\331\256\356\351\037\367\326"}
    #   pp.to_encrypted
    #   # => {:username=>"mysql_username", :encrypted_password=>"\345?r`\222\021"\210\312\331\256\356\351\037\367\326"}
    #
    def to_encrypted
      reject{|attr, val| decrypted_attr?(attr) }.to_hash
    end
    #
    # A hash containing only regular and decrypted pairs, with the "decrypted_" prefix stripped from keys
    #
    # Example:
    #   pp
    #   # => {:username=>"mysql_username", :decrypted_password=>"mysql_password", :encrypted_password=>"\345?r`\222\021"\210\312\331\256\356\351\037\367\326"}
    #   pp.to_plain
    #   # => {:username=>"mysql_username", :password=>"mysql_password"}
    #
    def to_plain
      plain = { }
      to_decrypted.each{|attr, val| plain[attr_base(attr).to_sym] = val }
      plain
    end

    #
    # These methods set values and so we have to ensure
    # encrypted and decrypted values stay in sync.
    #

    def merge! hsh
      super hsh
      hsh.each{|attr, val| self[attr] = val if special_attr?(attr) }
      self
    end
    def replace hsh
      super hsh
      sync!
      self
    end
    def delete(attr)
      super(attr_counterpart(attr)) if special_attr?(attr)
      super(attr)
    end
    def delete_if!(*args, &block) raise "Not implemented" ; end
    def reject!(*args, &block)    raise "Not implemented" ; end
    def default=(*args, &block)   raise "Not implemented" ; end
    def shift()                   raise "Not implemented" ; end
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

    # ensures that for each decrypted value its correct encrypted counterpart
    # exists, and vice versa.
    def sync!
      each do |attr, val|
        self[attr] = val if special_attr?(attr)
      end
    end

    # is this an attribute for an encrypted value?
    def encrypted_attr? attr
      $1 if attr.to_s =~ /^encrypted_(.*)/
    end
    # is this an attribute for a decrypted value?
    def decrypted_attr? attr
      $1 if attr.to_s =~ /^decrypted_(.*)/
    end
    # is this an attribute for a special (encrypted or decrypted) value?
    def special_attr? attr
      encrypted_attr?(attr) || decrypted_attr?(attr)
    end
    # given an en-crypted or de-crypted attribute name, returns its de- or en- counterpart
    def attr_counterpart attr
      attr.to_s.gsub(/^(en|de)crypted_/){ $1 == 'en' ? 'decrypted_' : 'encrypted_'}.to_sym
    end
    # the base part of a special attribute name, or the whole thing if it's not special.
    def attr_base attr
      attr.to_s.gsub(/^(en|de)crypted_/, "")
    end
  end
end
