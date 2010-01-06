require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "configliere"
    gem.summary = %Q{Wise, discreet configuration management}
    gem.description = %Q{ You've got a script. It's got some settings. Some settings are for this module, some are for that module. Most of them don't change. Except on your laptop, where the paths are different.  Or when you're in production mode. Or when you're testing from the command line.

   "" So, Consigliere of mine, I think you should tell your Don what everyone knows. "" -- Don Corleone

Configliere's wise counsel takes care of these problems. Design goals:

* *Don't go outside the family*. Requires almost no external resources and almost no code in your script.
* *Don't mess with my crew*. Settings for a model over here can be done independently of settings for a model over there, and don't require asking the boss to set something up.
* *Be willing to sit down with the Five Families*. Takes settings from (at your option):
** Pre-defined defaults from constants
** Simple config files
** Environment variables
** Commandline options
** Ruby block called when all other options are in place
* *Code of Silence*. Most commandline parsers force you to pre-define all your parameters in a centralized and wordy syntax. In configliere, you pre-define nothing -- commandline parameters map directly to values in the Configliere hash.
* *Can hide your assets*. Rather than storing passwords and API keys in plain sight, configliere has a protection racket that can obscure values when stored to disk.

fuhgeddaboudit.
} #'
    gem.email = "flip@infochimps.org"
    gem.homepage = "http://github.com/mrflip/configliere"
    gem.authors = ["mrflip"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "yard", ">= 0"
    gem.add_dependency "highline", ">= 0"
    gem.add_dependency "yaml", ">= 0"
    gem.add_dependency "openssl", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

begin
  require 'reek/adapters/rake_task'
  Reek::RakeTask.new do |t|
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
