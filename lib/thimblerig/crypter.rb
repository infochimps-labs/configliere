module Thimblerig
  #
  # Encrypt and decrypt values in thimble stores
  #
  module Crypter
    def self.new_cipher direction, passpass, iv=nil, options={}
      cipher     = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
      case direction when :encrypt then cipher.encrypt when :decrypt then cipher.decrypt else raise "Bad cipher direction #{direction}" end
      cipher.key = encrypt_key(passpass, options)
      iv     ||= cipher.random_iv
      cipher.iv  = iv
      cipher
    end
    def self.random_iv
      cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
      cipher.random_iv
    end
    def self.encrypt plaintext, passpass, iv, options={}
      cipher     = new_cipher :encrypt, passpass, iv, options
      ciphertext = cipher.update(plaintext)
      ciphertext << cipher.final
      ciphertext
    end
    def self.decrypt ciphertext, passpass, iv, options={}
      cipher     = new_cipher :decrypt, passpass, iv, options
      plaintext  = cipher.update(ciphertext)
      plaintext  << cipher.final
      plaintext
    end
    #
    # identify the machine we're on
    #
    def self.hostname
      return @hostname if @hostname
      require "socket"
      @hostname = Socket.gethostname
    end
    def self.override_hostname str
      @hostname = str
    end
    def self.macaddr
      return @macaddr if @macaddr
      require "macaddr"
      @macaddr = Mac.addr
    end
    def self.override_macaddr str
      @macaddr = str
    end

    def self.encrypt_key passpass, options={}
      keyparts = {
        'hostname'   => keypart_from_hostname(options),
        'macaddr'    => keypart_from_macaddr(options),
      }.compact.map{|part,val| "#{part}=#{CGI.escape(val)}" }.sort
      keyparts.unshift passpass
      Digest::SHA1.hexdigest(keyparts.join('&'))
    end
    def self.keypart_from_hostname options
      return unless val = options[:hostname]
      (val==true) ? Crypter.hostname : val
    end
    def self.keypart_from_macaddr options
      return unless val = options[:macaddr]
      (val==true) ? Crypter.macaddr : val
    end
  end
end
