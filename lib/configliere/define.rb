module Configliere
  module Define
    def define param, definitions
      # definitions.each do
      # end
      self.param_definitions[param]= definitions
    end

    def initialize *args, &block
      super *args, &block
      self.param_definitions = {}
    end

    def self.included base
      base.class_eval do
        attr_accessor :param_definitions
      end
    end
  end

  Param.class_eval do
    include Configliere::Define
  end
end

