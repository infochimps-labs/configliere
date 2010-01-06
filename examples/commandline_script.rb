#!/usr/bin/env ruby
require 'rubygems' ; $: << File.dirname(__FILE__)+'/../lib'
require 'pp'
# module Configliere ; DEFAULT_CONFIG_FILENAME = File.dirname(__FILE__)+'/commandline_script.yaml' end
require 'configliere'

Settings.use :commandline, :define, :environment, :param_store, :encrypted

puts %Q{
This is a demo of the Configliere interface. It parses all command line options to load keys, global options, etc.

Try running it as

   PLACES='go' NOISES='who' ./examples/simple_script.rb --cat=hat

which should create

    {:cat=>"hat", :places=>"go", :horton=>{:hears_a=>"who"}, :wocket=>"pocket", :key => '[what you entered]'}
}

# describe and define params
Settings.define :cat,    :description => 'The type of feline haberdashery to include in the story', :required => true, :type => Symbol
Settings.define :wocket, :description => 'where the wocket is residing'
Settings.define :password, :encrypted => true

# static settings
Settings :wocket => 'pocket', :key => 'asdf'
# from environment
Settings.environment_variables 'PLACES', 'NOISES' => 'horton.hears_a'
# from config file
Settings.read(File.dirname(__FILE__)+'/simple_script.yaml')

# bookkeeping
Settings.resolve!
# Get the value for param[:key] from the keyboard if missing
Settings.param_or_ask :key

p Settings

Settings.save! File.dirname(__FILE__)+'/foo.yaml'


# puts %Q{
# ---------------------------------------------------------------------------
#
# Here\'s the one-line version. It loads the file, takes the key from the
# commandline or a prompt, and extracts the decrypted hash of values.
#
# To supply the key from the command line, run
#   #{$0} --key=foobar
# }
#
# puts %Q{
# ---------------------------------------------------------------------------
#
# If you\'d like access to the command-line options as well, keep the client
# around. In this example, we load config options from the param group but allow
# the commandline options to override.
#
# To supply some override options, try
#   #{$0} --key=foobar --email_address="me@example.com" --password="alt_pass"
# }
#
# configliere_client = Configliere::Client.new
# config = configliere_client.get(:example).to_plain
# config.merge! configliere_client.external_options
#
# print "Configuration with override: "
# pp config

