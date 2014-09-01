require 'date'                      # type conversion
require 'time'                      # type conversion
require 'fileutils'                 # so save! can mkdir

require 'multi_json'
require 'yaml'

require 'configliere/deep_hash'     # magic hash for params
require 'configliere/param'         # params container
require 'configliere/define'        # define param behavior
require 'configliere/config_file'   # read / save! files

# use(:encrypted) will bring in 'digest/sha2' and 'openssl'
# use(:prompt)    will bring in 'highline', which you must gem install
# running the specs requires rspec and spork

module Configliere
  RUBY_ENGINE = 'ruby' if not defined?(::RUBY_ENGINE)

  ALL_MIXINS = [:define, :config_file, :commandline, :encrypted, :env_var, :config_block, :commands, :prompt]
  def self.use *mixins
    mixins = ALL_MIXINS if mixins.include?(:all) || mixins.empty?
    mixins.each do |mixin|
      require "configliere/#{mixin}"
    end
  end

end

# Base class for Configliere errors.
class Configliere::Error           < StandardError      ; end
# Feature is deprecated, has or will leave the building
class Configliere::DeprecatedError < Configliere::Error ; end

# Defines a global config object
Settings = Configliere::Param.new unless defined?(Settings)

#
# Also define Settings as a function, so you can say
#   Settings :this => that, :cat => :hat
#
def Settings *args
  Settings.defaults(*args)
end
