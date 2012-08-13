require 'bundler/setup' ; Bundler.require(:default, :development, :test)
require 'rspec/autorun'

puts "Running specs in version #{RUBY_VERSION} on #{RUBY_PLATFORM} #{RUBY_DESCRIPTION}"

if ENV['CONFIGLIERE_COV']
  require 'simplecov'
  SimpleCov.start
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true

  def load_sketchy_lib(lib)
    begin
      require lib
      yield if block_given?
      return true
    rescue LoadError, StandardError => err
      warn "#{RUBY_DESCRIPTION} doesn't seem to like #{lib}: got error"
      warn "  #{err.class} #{err}"
      warn "Skipping specs on '#{caller(2).first}'"
      return false
    end
  end

  def capture_help_message
    stderr_output = ''
    subject.should_receive(:warn){|str| stderr_output << str }
    begin
      yield
      fail('should exit via system exit')
    rescue SystemExit
      true # pass
    end
    stderr_output
  end

  def check_openssl
    load_sketchy_lib('openssl') do
      p OpenSSL::Cipher.ciphers
      cipher = OpenSSL::Cipher::Cipher.new('aes-128-cbc')
      p cipher
      cipher.encrypt
      cipher.key = Digest::SHA256.digest("HI JRUBY")
      cipher.iv  = iv = cipher.random_iv
      ciphertext = cipher.update("O HAI TO YOU!")
      ciphertext << cipher.final
      p [__LINE__, ciphertext]
      cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
      cipher.encrypt
      cipher.key = Digest::SHA256.digest("HI JRUBY")
      cipher.iv  = iv = cipher.random_iv
      ciphertext = cipher.update("O HAI TO YOU!")
      ciphertext << cipher.final
      p [__LINE__, ciphertext]
    end
  end

end

require 'configliere'
