#!/usr/bin/env ruby
require 'rubygems' ; $: << File.dirname(__FILE__)+'/../lib'
require 'thimblerig'
require 'thimblerig/client'
Log = Logger.new(STDERR) unless defined?(Log)

th = Thimblerig::Client.new

th.get(example)
