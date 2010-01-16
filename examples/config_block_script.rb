#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../lib'
require 'configliere'
Settings.use :config_block

Settings.define :passenger
Settings.define :dest_time, :type => DateTime
Settings :passenger => 'einstein', :dest_time => '1955-11-05'

Settings.finally do |c|
  p [self, 'finally', c[:passenger], c.passenger]
  # Einstein the dog should only be sent one minute into the future.
  c.dest_time = (Time.now + 60) if c.passenger == 'einstein'
end
Settings.resolve!
p Settings
