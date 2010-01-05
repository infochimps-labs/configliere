#!/usr/bin/env ruby
require 'rubygems' ; $: << File.dirname(__FILE__)+'/../lib'
require 'pp'
# module Thimblerig ; DEFAULT_FILENAME = File.dirname(__FILE__)+'/thimblerig_example_store.yaml' end
require 'thimblerig'
require 'thimblerig/client'

Thimblerig.save('foobar',
  :email_address      => 'bob@company.com',
  :decrypted_password => 'my_password',
  :rate_per_hour      => 10,
  :smtp_domain        => 'smtp.company.com',
  :_thimble_options   => { :hostname => false })


puts %Q{
This is a demo of the Thimblerig::Client. It parses all command line options to load keys, global options, etc.
}

puts %Q{
---------------------------------------------------------------------------

Here\'s the one-line version. It loads the file, takes the key from the
commandline or a prompt, and extracts the decrypted hash of values.

To supply the key from the command line, run
  #{$0} --key=foobar

}
# Load the config!
config = Thimblerig::Client.new.get(:example)
puts "Simple load: #{config}"

puts %Q{
---------------------------------------------------------------------------

If you\'d like access to the command-line options as well, keep the client
around. In this example, we load config options from the thimble but allow
the commandline options to override.

To supply some override options, try
  #{$0} --key=foobar --email_address="me@example.com" --password="alt_pass"

}

thimble_client = Thimblerig::Client.new
config = thimble_client.get(:example).to_plain
config.merge! thimble_client.external_options

print "Configuration with override: "
pp config


# ===========================================================================
#
#

File.dirname(__FILE__)+'/thimblerig_example_store.yaml'
