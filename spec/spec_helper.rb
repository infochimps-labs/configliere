require 'bundler/setup' ; Bundler.require(:default, :development, :test)
require 'rspec/autorun'

puts "Running specs in version #{RUBY_VERSION} on #{RUBY_PLATFORM} #{RUBY_DESCRIPTION}"

if ENV['CONFIGLIERE_COV']
  require 'simplecov'
  SimpleCov.start
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true

  def load_sketchy_lib(lib, sentinel)
    begin
      require lib
      return true
    rescue LoadError, StandardError => err
      raise unless (err.to_s =~ sentinel)
      warn "#{RUBY_DESCRIPTION} doesn't seem to like #{lib}. Sorry!"
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

end

require 'configliere'
