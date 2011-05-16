#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../lib'
require 'configliere'

puts "This is a demo of Configliere in a simple script."
Settings.use :commandline

puts "\n\nSet default values inline:"

Settings({
  :heavy => true,
  :delorean => {
    :power_source => 'plutonium',
    :roads_needed => true,
    },
  :username => 'marty',
  })
puts "\n  #{Settings.inspect}"

puts "\nYou can define settings' type, default value, and description (that shows up with --help), and more. It's purely optional, but it's very convenient:"

Settings.define :dest_time, :default => '11-05-1955', :type => Time, :description => "Target date"
# This defines a 'deep key': it controls Settings[:delorean][:roads_needed]
Settings.define 'delorean.roads_needed', :type => :boolean
Settings.define 'username', :env_var => 'DRIVER'
puts "\n  #{Settings.inspect}"

config_filename = File.dirname(__FILE__)+'/simple_script.yaml'
puts "\nValues loaded from the file #{config_filename} merge with the existing defaults:"

Settings.read config_filename
puts "\n  #{Settings.inspect}"

puts %Q{\nFinally, call resolve! to load the commandline you gave (#{ARGV.inspect}), do type conversion (watch what happens to :dest_time), etc:}
Settings.resolve!
puts "\n  #{Settings.inspect}"

saved_filename = '/tmp/simple_script_saved.yaml'
puts %Q{\nYou can save the defaults out to a config file -- go look in #{saved_filename}}
Settings.save!(saved_filename)

if ARGV.empty?
  puts %Q{\nTry running the script again, but supply some commandline args:\n
    DRIVER=doc #{$0} --dest_time=11-05-2015 --delorean.roads_needed=false --delorean.power_source="Mr. Fusion"}
end
puts

