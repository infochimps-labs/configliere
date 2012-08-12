# encoding: UTF-8
require 'rubygems' unless defined?(Gem)
require 'rspec'

if ENV['CONFIGLIERE_COV']
  require 'simplecov'
  SimpleCov.start
end

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'configliere'
require 'json'
require 'yaml'
