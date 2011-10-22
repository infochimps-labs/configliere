source "http://rubygems.org"

gem 'json'

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem 'bundler',   "~> 1.0.12"
  gem 'yard',      "~> 0.6.7"
  gem 'jeweler',         "~> 1.6.4"
  gem 'rspec',     "~> 2.5.0"
  gem 'spork',     "~> 0.9.0.rc5"
  gem 'RedCloth' # for yard
end

group :development do
  # Only necessary if you want to use Configliere::Prompt
  gem 'highline',  ">= 1.5.2"
end

group :optional do
  # only interesting for coverage testing
  gem 'rcov',      ">= 0.9.9"
  gem 'reek'
  gem 'roodi'
  gem 'watchr'
end
