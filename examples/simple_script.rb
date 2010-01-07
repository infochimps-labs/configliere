#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../lib'
require 'configliere'

# Intro text
puts %Q{
This is a demo of the Configliere interface. It takse settings
Try running it as
  ./examples/simple_script.rb --sprats.wife=fat --spider=drainspout
with those args, we
  expect: {:spider=>"drainspout", :cat=>"hat", :sprats=>{:wife=>"fat", :jack=>"lean"}, :cow=>"moon"}
}

Settings.use(:commandline, :config_file,
      :cat => 'bag', :cow => 'moon')
Settings.read File.dirname(__FILE__)+'/simple_script.yaml'
Settings.resolve!

# Print results
print '  actual: '
p Settings
