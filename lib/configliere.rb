require 'yaml'
require 'fileutils'
require 'configliere/deep_hash'
require 'configliere/param'
require 'configliere/define'
require 'configliere/config_file'

module Configliere
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
