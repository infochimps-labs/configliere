# -*- encoding: utf-8 -*-
require File.expand_path('../lib/configliere/version', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'configliere'
  s.homepage      = 'https://github.com/infochimps-labs/configliere'
  s.license       = 'Apache 2.0'
  s.email         = 'coders@infochimps.org'
  s.authors       = ['Infochimps']
  s.version       = Configliere::VERSION
  s.summary       = 'Wise, discreet configuration management'
  s.description   = <<-EOF.gsub(/^ {4}/, '')
    You've got a script. It's got some settings. Some settings are for this module, some are for that module. Most of them don't change. 
    Except on your laptop, where the paths are different.  Or when you're in production mode. Or when you're testing from the command line.

      "So, Consigliere of mine, I think you should tell your Don what everyone knows." -- Don Corleone

    Configliere manages settings from many sources: static constants, simple config files, environment variables, commandline options, and straight ruby.
    You don't have to predefine anything, but you can ask configliere to type-convert, require, document and/or password-obscure any of its fields. 
    Modules can define config settings independently of each other and the main program.
  EOF
  
  s.files         = `git ls-files`.split("\n")
  s.executables   = []
  s.require_paths = ['lib']
end
