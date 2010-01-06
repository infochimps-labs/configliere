#!/usr/bin/env ruby
require 'rubygems' ; $: << File.dirname(__FILE__)+'/../lib'
require 'configliere'
SCRIPT_DIR = File.dirname(__FILE__)

# Intro text
puts %Q{
This is a demo of the Configliere interface. It takse settings
Try running it as
   ./examples/simple_script.rb --cat=hat
with those args, we
  expect: {:things=>["thing_1", "thing_2"], :rate_per_hour=>10, :cat=>"hat"}
}

# Configuration
Settings.use :commandline, :param_store, :config_blocks
Settings.read SCRIPT_DIR+'/simple_script.yaml'

Settings.resolve!

# Print results
print '  actual: '
p Settings
