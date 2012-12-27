require 'rubygems' unless defined?(Gem)

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:rspec)

desc 'Run RSpec with code coverage'
task :cov do
  ENV['CONFIGLIERE_COV'] = 'yep'
  Rake::Task[:rspec].execute
end

require 'yard'
YARD::Rake::YardocTask.new

task :default => :rspec
