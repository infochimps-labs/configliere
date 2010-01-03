module Thimblerig
  #
  # Encrypt and decrypt values in thimble stores
  #
  module Crypter
    #
    # Encrypt the given string, using the key and iv supplied
    #
    def self.encrypt plaintext, thimble_key, iv, options={}
      cipher     = new_cipher :encrypt, thimble_key, iv, options
      ciphertext = cipher.update(plaintext)
      ciphertext << cipher.final
      ciphertext
    end
    #
    # Decrypt the given string, using the key and iv supplied
    #
    def self.decrypt ciphertext, thimble_key, iv, options={}
      cipher     = new_cipher :decrypt, thimble_key, iv, options
      plaintext  = cipher.update(ciphertext)
      plaintext  << cipher.final
      plaintext
    end
    #
    # Create a new cipher machine, with its dials set in the direction given
    # (either :encrypt or :decrypt).
    #
    def self.new_cipher direction, thimble_key, iv=nil, options={}
      cipher     = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
      case direction when :encrypt then cipher.encrypt when :decrypt then cipher.decrypt else raise "Bad cipher direction #{direction}" end
      cipher.key = encrypt_key(thimble_key, options)
      iv     ||= cipher.random_iv
      cipher.iv  = iv
      cipher
    end
    # Convert the thimble_key passphrase into the key used for encryption
    def self.encrypt_key thimble_key, options={}
      Digest::SHA1.hexdigest(thimble_key)
    end
    # Return a random IV to
    def self.random_iv
      cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
      cipher.random_iv
    end
  end
end
