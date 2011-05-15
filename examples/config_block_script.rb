#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../lib'
require 'configliere'
Settings.use :config_block

Settings.define :passenger
Settings.define :dest_time, :type => DateTime
Settings :passenger => 'einstein', :dest_time => '1955-11-05'

Settings.finally do |c|
  p ['(2) takes the settings object as arg', self, c[:passenger], c.passenger]
  # Einstein the dog should only be sent one minute into the future.
  c.dest_time = (Time.now + 60) if c.passenger == 'einstein'
end

Settings.finally{ p ['(3) note that blocks go in order'] }

Settings.define :mc_fly, :default => 'wuss',
  :finally => lambda{ p ['(4) here is a block in the define'] ; Settings.mc_fly = 'badass' }

p ["(1) :finally blocks are called when you invoke resolve!"]
Settings.resolve!
p ['(5) here are the settings', Settings]
