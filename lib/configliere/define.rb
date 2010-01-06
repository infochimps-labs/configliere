module Configliere
  module Define
    # Definitions for params: :description, :type, :encrypted, etc.
    attr_accessor :param_definitions

    def initialize *args, &block
      super *args, &block
      self.param_definitions = {}
    end

    def define param, definitions
      self.param_definitions[param]= definitions
    end

    def description param
      definition = param_definitions[param] or return
      definition[:description]
    end
  end

  Param.class_eval do
    include Configliere::Define
  end
end

