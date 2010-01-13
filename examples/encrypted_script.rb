#!/usr/bin/env ruby
require 'configliere'

Settings.use :config_file, :define, :encrypt_pass => 'password1'
Settings.define 'password', :required => true, :encrypted => true
Settings 'password' => 'plaintext'
p Settings
Settings.resolve!
p Settings
p Settings.send(:export)
Settings.save!('file.yml')

Settings.password = 'before read'
Settings.read('file.yml')
Settings.password = 'before resolve'
Settings.resolve!
p Settings
