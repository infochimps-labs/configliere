source "http://rubygems.org"

gem   'multi_json',  ">= 1.1"

# Only necessary if you want to use Configliere::Prompt
gem   'highline',    ">= 1.5.2"
gem   'jruby-openssl', :platform => :jruby if RUBY_PLATFORM =~ /jruby/

# Only gems that you want listed as development dependencies in the gemspec
group :development do
  gem 'bundler',     "~> 1.1"
  gem 'rake'
  gem 'yard',        ">= 0.7"
  gem 'rspec',       "~> 2.8"
  gem 'jeweler',     ">= 1.6"
  #
  gem 'oj',          ">= 1.2",   :platform => :ruby
  gem 'json',                    :platform => :jruby
end

group :docs do
  gem 'RedCloth',    ">= 4.2", :require => "redcloth"
  gem 'redcarpet',   ">= 2.1"
end

# Gems for testing and coverage
group :test do
  gem 'simplecov',   ">= 0.5", :platform => :ruby_19
end

# Gems you would use if hacking on this gem (rather than with it)
group :support do
  gem 'pry'
  gem 'guard',       ">= 1.0"
  gem 'guard-rspec', ">= 0.6"
  gem 'guard-yard'
  if RUBY_PLATFORM.include?('darwin')
    gem 'rb-fsevent', ">= 0.9"
  end
end
