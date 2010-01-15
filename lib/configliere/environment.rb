require 'yaml'
Configliere.use :define
module Configliere
  #
  # Environment -- load configuration from environment variables
  #
  module Environment
    def environment_variables *envs
      envs.each do |env|
        case env
        when Hash
          env.each do |param, env|
            adopt_environment_variable! param, env
          end
        else
          param = env.to_s.downcase.to_sym
          adopt_environment_variable! param, env
        end
      end
    end

    def params_from_environment
      definitions_for(:environment)
    end

  protected
    def adopt_environment_variable! param, env
      env   = env.to_s
      param_definitions[param][:environment] ||= env
      val = ENV[env]
      self[param] = val if val
    end
  end

  Param.class_eval do
    # include read / save operations
    include Environment
  end
end

