require 'configliere/core_ext'
require 'configliere/param'
require 'configliere/define'
require 'configliere/config_file'

module Configliere

  # delegates to Configliere::Param
  def self.new *args, &block
    Configliere::Param.new(*args, &block)
  end

  ALL_MIXINS = [:define, :config_file, :commandline, :encrypted, :env_var, :config_block, :commands]
  def self.use *mixins
    mixins = ALL_MIXINS if mixins.include?(:all) || mixins.empty?
    mixins.each do |mixin|
      # backwards compatibility
      if mixin.to_sym == :git_style_binaries
        require "configliere/commands"
      else
        require "configliere/#{mixin}"
      end
    end
  end

  # Base class for Configliere errors.
  Error = Class.new(StandardError)

end

# Defines a global config object
Settings = Configliere.new unless defined?(Settings)

#
# Allows the
#   Config :this => that, :cat => :hat
# pattern.
#
def Settings *args
  Settings.defaults(*args)
end
