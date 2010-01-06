Configliere.use :define
module Configliere
  module Block
    # Config blocks to be executed at end of resolution (just before validation)
    attr_accessor :final_blocks

    def initialize *args, &block
      super *args, &block
      self.final_blocks = []
    end

    # @params param the setting to describe. Either a simple symbol or a dotted param string.
    # @params definitions the defineables to set (:description, :type, :encrypted, etc.)
    #
    # @example
    #   Settings.define :dest_time, :type => Date, :description => 'Arrival time. If only a date is given, the current time of day on that date is assumed.'
    #   Settings.define 'delorean.power_source', :description => 'Delorean subsytem supplying power to the Flux Capacitor.'
    #   Settings.define :password, :required => true, :obscure => true
    #
    def finally &block
      self.final_blocks << block
    end

    # calls superclass resolution
    def resolve!
      begin ; super() ; rescue NoMethodError ; nil ; end
      resolve_finally_blocks!
      self
    end

  protected
    def resolve_finally_blocks!
      final_blocks.each do |block|
        block.call(self)
      end
    end

  end

  Param.class_eval do
    include Configliere::Block
  end
end
