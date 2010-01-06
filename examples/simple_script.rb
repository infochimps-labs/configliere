#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../lib'
require 'configliere'

# Intro text
puts %Q{
This is a demo of the Configliere interface. It takse settings
Try running it as
  ./examples/simple_script.rb --sprats.wife=fat --spider=drainspout
with those args, we
  expect: {:cat=>"hat", :spider=>"drainspout", :sprats=>{:jack=>"lean", :wife=>"fat"}}
}

Settings.use :commandline, :config_file
Settings.read File.dirname(__FILE__)+'/simple_script.yaml'
Settings.resolve!

# Print results
print '  actual: '
p Settings
