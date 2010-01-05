#!/usr/bin/env ruby
require 'rubygems' ; $: << File.dirname(__FILE__)+'/../lib'
require 'configliere'

SCRIPT_PASSWORD = File.expand_path($0)

Configliere.save(SCRIPT_PASSWORD,
  :username => 'bob', :decrypted_password => 'my_password', :rate_per_hour => 10,
  :_configliere_options => { :hostname => true, :macaddr => false })


th = Configliere.load SCRIPT_PASSWORD
puts th
