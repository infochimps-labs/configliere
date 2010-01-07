require 'openssl'
require 'digest/sha2'
module Configliere
  #
  # Encrypt and decrypt values in configliere stores
  #
  module Crypter
    CIPHER_TYPE = "aes-256-cbc" unless defined?(CIPHER_TYPE)

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
      combine_iv_and_ciphertext(iv, ciphertext)
    end
    #
    # Decrypt the given string, using the key and iv supplied
    #
    # @param ciphertext the text to decrypt, probably produced with Crypter#decrypt
    # @param [String] encrypt_pass secret passphrase to decrypt with
    # @return [String] the decrypted plaintext
    #
    def self.decrypt iv_and_ciphertext, encrypt_pass, options={}
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
      cipher     = OpenSSL::Cipher::Cipher.new(CIPHER_TYPE)
      case direction when :encrypt then cipher.encrypt when :decrypt then cipher.decrypt else raise "Bad cipher direction #{direction}" end
      cipher.key = encrypt_key(encrypt_pass, options)
      cipher
    end

    # prepend the initialization vector to the encoded message
    def self.combine_iv_and_ciphertext iv, message
      iv + message
    end
    # pull the initialization vector from the front of the encoded message
    def self.separate_iv_and_ciphertext cipher, iv_and_ciphertext
      idx = cipher.iv_len
      [ iv_and_ciphertext[0..(idx-1)], iv_and_ciphertext[idx..-1] ]
    end

    # Convert the encrypt_pass passphrase into the key used for encryption
    def self.encrypt_key encrypt_pass, options={}
      raise 'Blank encryption password!' if encrypt_pass.blank?
      # this provides the required 256 bits of key for the aes-256-cbc cipher
      Digest::SHA256.digest(encrypt_pass)
    end
  end
end
