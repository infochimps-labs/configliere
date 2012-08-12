require 'bundler/setup' ; Bundler.require(:default, :development, :test)
require 'rspec/autorun'

if ENV['CONFIGLIERE_COV']
  require 'simplecov'
  SimpleCov.start
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
end

require 'configliere'
