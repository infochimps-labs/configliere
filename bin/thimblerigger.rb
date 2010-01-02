#!/usr/bin/env ruby
require 'rubygems' ; $: << File.dirname(__FILE__)+'/../lib'
require 'thimblerig'
require 'thimblerig/client'
require 'thimblerig/client/commands'
Log = Logger.new(STDERR) unless defined?(Log)

class Thimblerigger < Thimblerig::Client
  def description
    %Q{Client for the thimblerig gem: manipulate configuration and passwords for automated scripts}
  end

  def process_options! *args
    super *args
    self.command = options[:_rest].shift.to_sym rescue nil
    self.handle  = options[:_rest].shift.to_sym rescue nil
    self.thimble_options = {}
    thimble_options[:hostname]   = options.delete(:hostname_in_key)
    thimble_options[:macaddr]    = options.delete(:macaddr_in_key)
    thimble_options.compact!
  end
end

Thimblerigger.new.run
