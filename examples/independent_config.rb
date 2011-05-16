#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../lib'
require 'configliere'

class Wolfman
  attr_accessor :config
  def config
    @config || = Configliere::Param.new.use(:commandline).defaults({
      :moon    => 'full',
      :nards   => true,
      })
  end
end

teen_wolf = Wolfman.new

teen_wolf.config.description = 'Run this with commandline args: Wolfman uses them, Settings does not'
teen_wolf.config.defaults(:give_me => 'keg of beer')

teen_wolf.config.resolve!
Settings.resolve!

# run this with ./examples/independent_config.rb --hi=there :
puts "If you run this with #{$0} --hi=there, you should expect:"
puts '{:moon=>"full", :nards=>true, :give_me=>"keg of beer", :hi=>"there"}'
p teen_wolf.config

puts 'the Settings hash should be empty:'
p Settings         #=> {}
