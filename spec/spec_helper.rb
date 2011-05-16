# encoding: UTF-8
require 'rubygems'
require 'spork'
require 'rspec'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster.
  # However, changes don't take effect until you restart spork.

  $LOAD_PATH.unshift(File.dirname(__FILE__))
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

  require 'configliere'

end

Spork.each_run do
  # This code will be run each time you run your specs.

end

