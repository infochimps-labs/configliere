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

  protected
    def adopt_env_var! param, env
      env   = env.to_s
      definition_of(param)[:env_var] ||= env
      val = ENV[env]
      self[param] = val if val
    end
  end

  Param.on_use(:env_var) do
    use :commandline
    extend Configliere::EnvVar
  end
end

