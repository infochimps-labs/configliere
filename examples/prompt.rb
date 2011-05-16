#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../lib'
require 'configliere'

Settings.use :commandline, :prompt
Settings.define :underpants, :description => 'boxers or briefs'
Settings.resolve!

puts %Q{
Configliere can prompt for a parameter value if none is given.
If you call this with a value for --underpants, you will not see a prompt
}

puts %Q{Using the commandline setting #{ARGV.grep(/^--underpants/).inspect}
your configliere advises that the settings are
  #{Settings.inspect}
}

puts Settings.prompt_for(:underpants)

puts %Q{Now the Settings are
  #{Settings.inspect}
}
