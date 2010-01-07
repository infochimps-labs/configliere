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
          env.each do |env, param|
            adopt_environment_variable! env.to_s, param
          end
        else
          param = env.to_s.downcase.to_sym
          adopt_environment_variable! env.to_s, param
        end
      end
    end

    def params_from_environment
      definitions_for(:environment)
    end

  protected
    def adopt_environment_variable! env, param
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

