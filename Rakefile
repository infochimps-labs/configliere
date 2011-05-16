require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "configliere"
    gem.homepage = "http://infochimps.com/labs"
    gem.license = "MIT"
    gem.summary = %Q{Wise, discreet configuration management}
    gem.description = %Q{ You've got a script. It's got some settings. Some settings are for this module, some are for that module. Most of them don't change. Except on your laptop, where the paths are different.  Or when you're in production mode. Or when you're testing from the command line.

   "" So, Consigliere of mine, I think you should tell your Don what everyone knows. "" -- Don Corleone

Configliere manage settings from many sources: static constants, simple config files, environment variables, commandline options, straight ruby. You don't have to predefine anything, but you can ask configliere to type-convert, require, document or password-obscure any of its fields. Modules can define config settings independently of each other and the main program.
} #'
    gem.email = "coders@infochimps.org"
    gem.authors = ["infochimps", "mrflip"]
  end
  Jeweler::RubygemsDotOrgTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end


require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

begin
  #
  # if rcov shits the bed with ruby 1.9, see
  #   https://github.com/relevance/rcov/issues/31
  #
  RSpec::Core::RakeTask.new(:rcov) do |spec|
    spec.pattern = 'spec/**/*_spec.rb'
    spec.rcov = true
    spec.rcov_opts = %w[ --exclude .rvm --no-comments --text-summary]
  end
rescue LoadError
  task :rspec do
    abort "Rspec is not available. In order to run spec, you must: sudo gem install rspec"
  end
end

begin
  require 'reek/rake/task'
  Reek::Rake::Task.new do |t|
    t.fail_on_error = true
    t.verbose = false
    t.source_files = 'lib/**/*.rb'
  end
rescue LoadError
  task :reek do
    abort "Reek is not available. In order to run reek, you must: sudo gem install reek"
  end
end

begin
  require 'roodi'
  require 'roodi_task'
  RoodiTask.new do |t|
    t.verbose = false
  end
rescue LoadError
  task :roodi do
    abort "Roodi is not available. In order to run roodi, you must: sudo gem install roodi"
  end
end

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
