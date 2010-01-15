#!/usr/bin/env ruby
require 'configliere'

Settings :passenger => 'einstein', :dest_time => '1955-11-05', 'delorean.power_source' => :plutonium
Settings.finally do |c|
  p [self, 'finally', c[:passenger], c.passenger]
  # Einstein the dog should only be sent one minute into the future.
  dest_time = (Time.now + 60) if c.passenger == 'einstein'
end
Settings.resolve!
p Settings
