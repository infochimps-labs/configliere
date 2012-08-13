module Configliere
  # for encryption

  begin
    require 'openssl'
    PLATFORM_ENCRYPTION_ERROR = nil
  rescue LoadError => err
    raise unless err.to_s.include?('openssl')
    warn "Your ruby doesn't appear to have been built with OpenSSL."
    warn "So you don't get to have Encryption."
    PLATFORM_ENCRYPTION_ERROR = err
  end

  require 'digest/sha2'
  # base64-encode the binary encrypted string
  require "base64"

  #
  # Encrypt and decrypt values in configliere stores
  #
  module Crypter
    CIPHER_TYPE = "aes-256-cbc" unless defined?(CIPHER_TYPE)

    def self.check_platform_can_encrypt!
      return true unless PLATFORM_ENCRYPTION_ERROR
      raise PLATFORM_ENCRYPTION_ERROR.class, "Encryption broken on this platform: #{PLATFORM_ENCRYPTION_ERROR}"
    end

    #
    # Encrypt the given string
    #
    # @param plaintext the text to encrypt
    # @param [String] encrypt_pass secret passphrase to encrypt with
    # @return [String] encrypted text, suitable for deciphering with Crypter#decrypt
    #
    def self.encrypt plaintext, encrypt_pass, options={}
      # The cipher's IV (Initialization Vector) is prepended (unencrypted) to
      # the ciphertext, which as far as I can tell is safe for our purposes:
      # http://www.ciphersbyritter.com/NEWS6/CBCIV.HTM
      cipher     = new_cipher :encrypt, encrypt_pass, options
      cipher.iv  = iv = cipher.random_iv
      ciphertext = cipher.update(plaintext)
      ciphertext << cipher.final
      Base64.encode64(combine_iv_and_ciphertext(iv, ciphertext))
    end
    #
    # Decrypt the given string, using the key and iv supplied
    #
    # @param ciphertext the text to decrypt, probably produced with Crypter#decrypt
    # @param [String] encrypt_pass secret passphrase to decrypt with
    # @return [String] the decrypted plaintext
    #
    def self.decrypt enc_ciphertext, encrypt_pass, options={}
      iv_and_ciphertext = Base64.decode64(enc_ciphertext)
      cipher    = new_cipher :decrypt, encrypt_pass, options
      cipher.iv, ciphertext = separate_iv_and_ciphertext(cipher, iv_and_ciphertext)
      plaintext = cipher.update(ciphertext)
      plaintext << cipher.final
      plaintext
    end
  protected
    #
    # Create a new cipher machine, with its dials set in the given direction
    #
    # @param [:encrypt, :decrypt] direction whether to encrypt or decrypt
    # @param [String] encrypt_pass secret passphrase to decrypt with
    #
    def self.new_cipher direction, encrypt_pass, options={}
      check_platform_can_encrypt!
      cipher     = OpenSSL::Cipher::Cipher.new(CIPHER_TYPE)
      case direction when :encrypt then cipher.encrypt when :decrypt then cipher.decrypt else raise "Bad cipher direction #{direction}" end
      cipher.key = encrypt_key(encrypt_pass, options)
      cipher
    end

    # prepend the initialization vector to the encoded message
    def self.combine_iv_and_ciphertext iv, message
      message.force_encoding("BINARY") if message.respond_to?(:force_encoding)
      iv.force_encoding("BINARY")      if iv.respond_to?(:force_encoding)
      iv + message
    end
    # pull the initialization vector from the front of the encoded message
    def self.separate_iv_and_ciphertext cipher, iv_and_ciphertext
      idx = cipher.iv_len
      [ iv_and_ciphertext[0..(idx-1)], iv_and_ciphertext[idx..-1] ]
    end

    # Convert the encrypt_pass passphrase into the key used for encryption
    def self.encrypt_key encrypt_pass, options={}
      encrypt_pass = encrypt_pass.to_s
      raise 'Missing encryption password!' if encrypt_pass.empty?
      # this provides the required 256 bits of key for the aes-256-cbc cipher
      Digest::SHA256.digest(encrypt_pass)
    end
  end
end
