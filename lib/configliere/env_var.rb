require 'yaml'
Configliere.use :define
module Configliere
  #
  # EnvVar -- load configuration from environment variables
  #
  module EnvVar
    def env_vars *envs
      envs.each do |env|
        case env
        when Hash
          env.each do |env_param, env_var|
            adopt_env_var! env_param, env_var
          end
        else
          param = env.to_s.downcase.to_sym
          adopt_env_var! param, env
        end
      end
    end

    def params_from_env_vars
      definitions_for(:env_var)
    end

  protected
    def adopt_env_var! param, env
      env   = env.to_s
      param_definitions[param][:env_var] ||= env
      val = ENV[env]
      self[param] = val if val
    end
  end

  Param.class_eval do
    # include read / save operations
    include EnvVar
  end
end

