module Configliere
  module Define
    # Definitions for params: :description, :type, :encrypted, etc.
    attr_accessor :param_definitions

    # @param param the setting to describe. Either a simple symbol or a dotted param string.
    # @param definitions the defineables to set (:description, :type, :encrypted, etc.)
    #
    # @example
    #   Settings.define :dest_time, :type => Date, :description => 'Arrival time. If only a date is given, the current time of day on that date is assumed.'
    #   Settings.define 'delorean.power_source', :description => 'Delorean subsytem supplying power to the Flux Capacitor.'
    #   Settings.define :password, :required => true, :obscure => true
    #
    def define param, definitions={}
      self.param_definitions[param].merge! definitions
      self.use(:env_var)   if definitions.include?(:env_var)
      self.use(:encrypted) if definitions.include?(:encrypted)
      self[param] = definitions[:default] if definitions.include?(:default)
      self.env_vars definitions[:env_var], param if definitions.include?(:env_var)
    end

    def param_definitions
      # initialize the param_definitions as an auto-vivifying hash if it's never been set
      @param_definitions ||= Sash.new{|hsh, key| hsh[key] = Sash.new  }
    end

    # performs type coercion
    def resolve!
      resolve_types!
      super()
      self
    end

    def validate!
      validate_requireds!
      super()
      true
    end

    # ===========================================================================
    #
    # Describe params with
    #
    #   Settings.define :param, :description => '...'
    #

    # gets the description (if any) for the param
    # @param param the setting to describe. Either a simple symbol or a dotted param string.
    def description_for param
      param_definitions[param][:description]
    end

    # All described params with their descriptions
    def descriptions
      definitions_for(:description).reject{|param, desc| param_definitions[param][:hide_help] }
    end

    # List of params that have descriptions
    def described_params
      params_with(:description)
    end

    # ===========================================================================
    #
    # Type coercion
    #
    # Define types with
    #
    #   Settings.define :param, :type => Date
    #

    def type_for param
      param_definitions[param][:type]
    end

    # All typed params with their descriptions
    def typed_params
      definitions_for(:type)
    end

    # List of params that have descriptions
    def typed_param_names
      params_with(:type)
    end

    require 'date'

    # Coerce all params with types defined to their proper form
    def resolve_types!
      typed_params.each do |param, type|
        val = self[param]
        case
        when val.nil?           then val = nil
        when (type == :boolean) then
          if ['false', false, 0, '0', ''].include?(val) then val = false else val = true end
        when ((type == Array) && val.is_a?(String))
          val = val.split(",")  rescue nil
          # following types map blank to nil
        when (val.blank?)       then val = nil
        when (type == Float)    then val = val.to_f
        when (type == Integer)  then val = val.to_i
        when (type == Symbol)   then val = val.to_s.to_sym     rescue nil
        when ((val.to_s == 'now') && (type == Date))     then val = Date.today
        when ((val.to_s == 'now') && (type == DateTime)) then val = DateTime.now
        when (type == Date)     then val = Date.parse(val)     rescue nil
        when (type == DateTime) then val = DateTime.parse(val) rescue nil
        else # nothing
        end
        self[param] = val
      end
    end

    # ===========================================================================
    #
    # Required params
    #
    # Define requireds with
    #
    #   Settings.define :param, :required => true
    #

    # List of params that are required
    # @return [Array] list of required params
    def required_params
      params_with(:required)
    end

    # Check that all required params are present.
    def validate_requireds!
      missing = []
      required_params.each do |param|
        missing << param if self[param].nil?
      end
      raise "Missing values for #{missing.map{|s| s.to_s }.sort.join(", ")}" if (! missing.empty?)
    end

    # all params with a value for the definable aspect
    #
    # @param definable the aspect to list (:description, :type, :encrypted, etc.)
    def params_with defineable
      param_definitions.keys.find_all{|param| param_definitions[param][defineable] } || []
    end

    # all params without a value for the definable aspect
    #
    # @param definable the aspect to reject (:description, :type, :encrypted, etc.)
    def params_without defineable
      param_definitions.keys.reject{|param| param_definitions[param].include?(defineable) } || []
    end

    def definitions_for defineable
      hsh = {}
      param_definitions.each do |param, defs|
        hsh[param] = defs[defineable] if defs[defineable]
      end
      hsh
    end

    # Pretend that any #define'd parameter is a method
    #
    # @example
    #   Settings.define :foo
    #   Settings.foo = 4
    #   Settings.foo      #=> 4
    def method_missing meth, *args
      meth.to_s =~ /^(\w+)(=)?$/ or return super
      name, setter = [$1.to_sym, $2]
      return(super) unless param_definitions.include?(name)
      if setter && (args.size == 1)
        self[name] = args.first
      elsif (!setter) && args.empty?
        self[name]
      else super ; end
    end

  end
  Param.class_eval do
    include Configliere::Define
  end
end

