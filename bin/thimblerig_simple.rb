#!/usr/bin/env ruby
require 'rubygems' ; $: << File.dirname(__FILE__)+'/../lib'
require 'thimblerig'

SCRIPT_PASSWORD = File.expand_path($0)

Thimblerig.save(SCRIPT_PASSWORD,
  :username => 'bob', :decrypted_password => 'my_password', :rate_per_hour => 10,
  :_thimble_options => { :hostname => true, :macaddr => false })


th = Thimblerig.load SCRIPT_PASSWORD
puts th
