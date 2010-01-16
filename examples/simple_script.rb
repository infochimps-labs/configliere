#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../lib'
require 'configliere'

puts "This is a demo of Configliere in a simple script."
Settings.use :commandline, :config_file

puts "You can set default values:"
Settings.defaults :cat => 'bag', :cow => 'moon'
puts "  #{Settings.inspect}"

config_filename = File.dirname(__FILE__)+'/simple_script.yaml'
puts "\nYou can load values from a file -- in this case, #{config_filename} -- which overrides the defaults:"
Settings.read config_filename
puts "  #{Settings.inspect}"

puts %Q{\nTry running the script with commandline parameters, for example
  #{$0} --sprats.wife=fat --spider=waterspout
In this case, you used
  #{$0} #{ARGV.join(" ")}
and so the final parameter values are}
Settings.resolve!
puts "  #{Settings.inspect}"

saved_filename = '/tmp/simple_script_saved.yaml'
puts %Q{\nYou can save the defaults out to a config file.  These settings have been written to #{saved_filename}}
Settings.save!(saved_filename)
