#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+"/../lib"
require 'configliere'
Settings.use :commandline

Settings.define :logfile, :type => String,     :description => "Log file name", :default => 'myapp.log', :required => false
Settings.define :debug, :type => :boolean,     :description => "Log debug messages to console?", :required => false
Settings.define :dest_time, :type => DateTime, :description => "Arrival time", :required => true
Settings.define :takes_opt, :flag => 't',      :description => "Takes a single-letter flag '-t'"
Settings.define :foobaz, :internal => true,    :description => "You won't see me"
Settings.define 'delorean.power_source', :env_var => 'POWER_SOURCE', :description => 'Delorean subsytem supplying power to the Flux Capacitor.'
Settings.define :password, :required => true, :encrypted => true
Settings.description = 'This is a sample script to demonstrate the help message. Notice how pretty everything lines up YAY'

Settings.resolve! rescue nil
puts "Run me again with --help to see the auto-generated help message!"
