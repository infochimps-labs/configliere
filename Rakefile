require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.setup(:default, :development)
require 'rake'

task :default => :rspec

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:rspec) do |spec|
  Bundler.setup(:default, :development, :test)
  spec.pattern = FileList['spec/**/*_spec.rb']
end

desc "Run RSpec with code coverage"
task :cov do
  ENV['CONFIGLIERE_COV'] = "yep"
  Rake::Task["spec"].execute
end

require 'yard'
YARD::Rake::YardocTask.new do
  Bundler.setup(:default, :development, :docs)
end

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name        = "configliere"
  gem.homepage    = "http://infochimps.com/tools"
  gem.license     = "Apache"
  gem.summary     = %Q{Wise, discreet configuration management}
  gem.email       = "coders@infochimps.org"
  gem.authors     = ["infochimps", "mrflip"]
  gem.executables = []
  gem.description = %Q{ You've got a script. It's got some settings. Some settings are for this module, some are for that module. Most of them don't change. Except on your laptop, where the paths are different.  Or when you're in production mode. Or when you're testing from the command line.

   "" So, Consigliere of mine, I think you should tell your Don what everyone knows. "" -- Don Corleone

Configliere manage settings from many sources: static constants, simple config files, environment variables, commandline options, straight ruby. You don't have to predefine anything, but you can ask configliere to type-convert, require, document or password-obscure any of its fields. Modules can define config settings independently of each other and the main program.
} #'
end
Jeweler::RubygemsDotOrgTasks.new
