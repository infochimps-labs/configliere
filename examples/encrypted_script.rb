#!/usr/bin/env ruby
require 'configliere'

DUMP_FILENAME = '/tmp/encrypted_script.yml'
Settings.use :config_file, :define, :encrypt_pass => 'password1'
Settings.define :password, :encrypted => true

Settings :password => 'plaintext'
Settings.resolve!
p ["saved version will have encrypted password (see #{DUMP_FILENAME}).", Settings.send(:export)]
p ['live version still has password in plaintext', Settings]
Settings.save!(DUMP_FILENAME)

Settings[:password] = 'before read'
Settings.read('/tmp/encrypted_script.yml')
Settings.resolve!
p ["value is decrypted on resolve.", Settings]
