#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../lib'
require 'configliere'
DUMP_FILENAME = '/tmp/encrypted_script.yml'

#
# Example usage:
#   export ENCRYPT_PASS=password1
#   ./examples/encrypted_script.rb
#

def dump_settings
  puts "  #{Settings.inspect} -- #{Settings.encrypt_pass}"
end

puts %Q{Many times, scripts need to save values you\'d rather not leave as
plaintext: API keys, database passwords, etc. Instead of leaving them in plain
sight, you may wish to obscure their value on disk and use a secondary password
to unlock it.

View source for this script to see commands you might use (from the irb console
or in a standalone script) to store the obscured values for later decryption.}

Settings.use :config_file, :define, :encrypted
Settings.encrypt_pass = 'password1'
Settings.define :secret, :encrypted => true, :default => 'plaintext'
Settings.resolve!

puts "\nIn-memory version still has secret in plaintext..."
dump_settings
puts "But the saved version will have encrypted secret (see #{DUMP_FILENAME}):"
puts "  #{Settings.send(:export).inspect}"
Settings.save!(DUMP_FILENAME)

puts "Let's reset the Settings:"
Settings.delete :secret
dump_settings
puts "If we now load the saved file, the parameter's value is decrypted on resolve:"
Settings.read('/tmp/encrypted_script.yml')
begin
  Settings.resolve!
rescue RuntimeError, OpenSSL::Cipher::CipherError => e
  warn "  #{e.class}: #{e}"
  warn "\nTry rerunning with \n  ENCRYPT_PASS=password1 #{$0} #{$ARGV}"
end
dump_settings

puts %Q{\nOf course, in your script you\'ll have to supply the decryption
password.  The best thing is to use an environment variable -- a user can spy on
your commandline parameters using "ps" or "top".  The following will fail unless
you supply the correct password ("password1") in the ENCRYPT_PASS environment
variable:\n\n}

Settings.encrypt_pass = ENV['ENCRYPT_PASS'] # this will happen normally, but we overrode it above

Settings.read('/tmp/encrypted_script.yml')
begin
  Settings.resolve!
  puts "You guessed the password!"
  dump_settings
rescue RuntimeError, OpenSSL::Cipher::CipherError => e
  warn "  #{e.class}: #{e}"
  warn "\nTry rerunning with \n  ENCRYPT_PASS=password1 #{$0} #{$ARGV}"
end
