#!/usr/bin/env ruby
require 'rubygems'
require 'configliere'

DUMP_FILENAME = '/tmp/encrypted_script.yml'
Settings.use :config_file, :define, :encrypt_pass => 'password1'
Settings.define :password, :encrypted => true

Settings :password => 'plaintext'
Settings.resolve!
puts 'Live version still has password in plaintext...'
p Settings
puts "But the saved version will have encrypted password (see #{DUMP_FILENAME}):"
p Settings.send(:export)
Settings.save!(DUMP_FILENAME)

Settings[:password] = 'before read'
Settings.read('/tmp/encrypted_script.yml')
Settings.resolve!
puts "When the saved file is loaded, value is decrypted on resolve:"
p Settings
