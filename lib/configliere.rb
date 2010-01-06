require 'configliere/core_ext'
require 'configliere/param'

module Configliere
  # Where to load params given only a symbol
  DEFAULT_CONFIG_FILE = ENV['HOME']+'/.configliere.yaml' unless defined?(DEFAULT_CONFIG_FILE)
  # Where to load params given a bare filename
  DEFAULT_CONFIG_DIR  = ENV['HOME']+'/.configliere'      unless defined?(DEFAULT_CONFIG_DIR)

  #
  #
  # delegates to Configliere::Param
  def self.new *args, &block
    Configliere::Param.new *args, &block
  end

  ALL_MIXINS = [:commandline, :crypter, :environment, :param_store]
  def self.use *mixins
    mixins = ALL_MIXINS if mixins.include?(:all)
    mixins.each do |mixin|
      require "configliere/#{mixin}"
    end
  end
end

# Defines a global config object
Config = Configliere.new unless defined?(Config)

#
# Allows the
#   Config :this => that, :cat => :hat
# pattern.
#
def Config *args
  Config.defaults *args
end
