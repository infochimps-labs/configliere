#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../lib'
require 'configliere'
Settings.use :config_block

Settings.define :passenger
Settings.define :dest_time, :type => DateTime
Settings :passenger => 'einstein', :dest_time => '1955-11-05'

Settings.finally do |c|
  p ['(second) takes the settings object as arg', self, c[:passenger], c.passenger]
  # Einstein the dog should only be sent one minute into the future.
  c.dest_time = (Time.now + 60) if c.passenger == 'einstein'
end

Settings.finally{ p ['(third), because blocks go in order'] }

p ["(first) :finally blocks are called when you invoke resolve!"]
Settings.resolve!
p ['(last) here are the settings', Settings]
