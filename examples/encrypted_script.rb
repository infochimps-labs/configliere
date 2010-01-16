#!/usr/bin/env ruby
require 'rubygems'
require 'configliere'
DUMP_FILENAME = '/tmp/encrypted_script.yml'

#
# Example usage:
#   export ENCRYPT_PASS=password1
#   ./examples/encrypted_script.rb
#

puts %Q{Many times, scripts need to save values you\'d rather not leave as
plaintext: API keys, database passwords, etc. Instead of leaving them in plain
sight, you may wish to obscure their value on disk and use a secondary password
to unlock it.

View source for this script to see commands you might use (from the irb console
or in a standalone script) to store the obscured values for later decryption.}

Settings.use :config_file, :define, :encrypted, :encrypt_pass => 'password1'
Settings.define :password, :encrypted => true, :default => 'plaintext'
Settings.resolve!

puts "\nIn-memory version still has password in plaintext..."
puts "  #{Settings.inspect}"
puts "But the saved version will have encrypted password (see #{DUMP_FILENAME}):"
puts "  #{Settings.send(:export).inspect}"
Settings.save!(DUMP_FILENAME)

puts "If we now load the saved file, the parameter's value is decrypted on resolve:"
Settings[:password] = 'nothing up my sleeve'
Settings.read('/tmp/encrypted_script.yml')
Settings.resolve!
puts "  #{Settings.inspect}"

# unset encrypt_pass
Settings.encrypt_pass = nil

puts %Q{\nOf course, in your script you\'ll have to supply the decryption
password.  The best thing is to use an environment variable -- a user can spy on
your commandline parameters using "ps" or "top".  The following will fail unless
you supply the correct password ("password1") in the ENCRYPT_PASS environment
variable:\n\n}

Settings.define :encrypt_pass, :env_var => 'ENCRYPT_PASS'
Settings.read('/tmp/encrypted_script.yml')
begin
  Settings.resolve!
  puts "  #{Settings.inspect}"
rescue RuntimeError => e
  warn "  #{e}"
end
