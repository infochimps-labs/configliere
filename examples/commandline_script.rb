#!/usr/bin/env ruby
require 'rubygems' ; $: << File.dirname(__FILE__)+'/../lib'
require 'pp'
# module Configliere ; DEFAULT_CONFIG_FILENAME = File.dirname(__FILE__)+'/commandline_script.yaml' end
require 'configliere'

Settings.use :commandline, :define, :environment, :param_store, :encrypted

puts %Q{
This is a demo of the Configliere interface. It parses all command line options to load keys, global options, etc.

Try running it as

   PLACES='go' NOISES='who' ./examples/simple_script.rb --cat=hat

which should create

  expect: {:password=>"zike_bike", :horton=>{:hears_a=>"who"}, :key=>"asdf", :cat=>"hat", :things=>["thing_1", "thing_2"], :rate_per_hour=>10, :places=>"go", :wocket=>"pocket"}
}

# describe and define params
Settings.define :cat,    :description => 'The type of feline haberdashery to include in the story', :required => true, :type => Symbol
Settings.define :wocket, :description => 'where the wocket is residing'
Settings.define :password, :encrypted => true

# static settings
Settings :wocket => 'pocket', :key => 'asdf'
# from environment
Settings.environment_variables 'PLACES', 'NOISES' => 'horton.hears_a'

# from config file
Settings.read(File.dirname(__FILE__)+'/commandline_script.yaml')

# from finally block
Settings.finally do |c|
  c.lorax = 'tree'
end

# bookkeeping
Settings.resolve!
# Get the value for param[:key] from the keyboard if missing
Settings.param_or_ask :key

# Print results
print '  actual: '
p Settings


fiddle = Configliere.new
fiddle.define 'amazon.api.key', :encrypted => true
fiddle[:'encrypted_amazon.api.key'] = "{bo\335\256nt2Rc\016\244\216c\030\2627g\233%\300\035l\225\325\305z\207LR\333\035"
print "actual: "; p [fiddle[:'encrypted_amazon.api.key'], fiddle['amazon.api.key'], fiddle.send(:export)]
fiddle.resolve!
puts  'expect: [nil, "bite_me"]'
print "actual: "; p [fiddle[:'encrypted_amazon.api.key'], fiddle['amazon.api.key'], fiddle.send(:export)]
#
fiddle = Configliere.new
fiddle['amazon.api.key'] = 'bite_me'
fiddle.resolve!
puts  'expect: [nil, "bite_me"]'
print "actual: "; p [fiddle.encrypted_api_key, fiddle.api_key, fiddle.send(:export)]
#
fiddle = Configliere.new
fiddle['amazon.api.encrypted_key'] = "{bo\335\256nt2Rc\016\244\216c\030\2627g\233%\300\035l\225\325\305z\207LR\333\035"
fiddle.resolve!
puts  'expect: [nil, "bite_me"]'
print "actual: "; p [fiddle.encrypted_api_key, fiddle.api_key, fiddle.send(:export)]



# save to disk
# you can check that :password and :api_key have been properly encrypted.
Settings.save! File.dirname(__FILE__)+'/foo.yaml'
