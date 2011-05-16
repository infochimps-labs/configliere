#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../lib'
require 'configliere'

puts "This is a demo of Configliere in a simple script."
Settings.use :commandline

puts "You can set default values:"
Settings({
  :heavy => false,
  :delorean => {
    :power_source => 'plutonium',
    :roads_needed => true,
    },
  })
puts "  #{Settings.inspect}"

puts "\nYou can define settings' type, default value, a description (that shows up with --help), and more. It's purely optional, but it's very convenient:"
Settings.define :dest_time, :default => '11-05-1955', :type => DateTime, :description => "Date to travel to"
Settings.define 'delorean.roads_needed', :type => :boolean
puts "  #{Settings.inspect}"

config_filename = File.dirname(__FILE__)+'/simple_script.yaml'
puts "\nYou can load values from a file -- in this case, #{config_filename} -- which overrides the defaults:"
Settings.read config_filename
Settings.resolve!
puts "  #{Settings.inspect}"
puts "Note that the date was automatically typecast when we called Settings.resolve!"


puts %Q{\nTry running the script with commandline parameters, for example
  #{$0} --dest_time=11-05-2015 --delorean.roads_needed=false --delorean.power_source="Mr. Fusion"
In this case, you used
  #{$0} #{ARGV.map{|argv| "'#{argv}'"}.join(" ")}
and so the final parameter values are}
Settings.resolve!
puts "  #{Settings.inspect}"

saved_filename = '/tmp/simple_script_saved.yaml'
puts %Q{\nYou can save the defaults out to a config file.  These settings have been written to #{saved_filename}}
Settings.save!(saved_filename)
