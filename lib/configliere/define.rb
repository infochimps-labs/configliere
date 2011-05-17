module Configliere
  module Define

    # Define arbitrary attributes of a param, notably:
    #
    # [:description]  Documentation for the param, used in the --help message
    # [:default]      Sets a default value (applied immediately)
    # [:env_var]      Environment variable to adopt (applied immediately, and after +:default+)
    # [:encrypted]    Obscures/Extracts the contents of this param when serialized
    # [:type]         Converts param's value to the given type, just before the finally block is called
    # [:finally]      Block of code to postprocess settings or handle complex configuration.
    # [:required]     Raises an error if, at the end of calling resolve!, the param's value is nil.
    #
    # @param param the setting to describe. Either a simple symbol or a dotted param string.
    # @param definitions the defineables to set (:description, :type, :encrypted, etc.)
    #
    # @example
    #   Settings.define :dest_time, :type => Date, :description => 'Arrival time. If only a date is given, the current time of day on that date is assumed.'
    #   Settings.define 'delorean.power_source', :description => 'Delorean subsytem supplying power to the Flux Capacitor.'
    #   Settings.define :password, :required => true, :obscure => true
    #   Settings.define :danger, :finally => lambda{|c| if c[:delorean][:power_source] == 'plutonium' than c.danger = 'high' }
    #
    def define param, pdefs={}, &block
      param = param.to_sym
      definitions[param].merge! pdefs
      self.use(:env_var)                      if pdefs.include?(:env_var)
      self.use(:encrypted)                    if pdefs.include?(:encrypted)
      self.use(:config_block)                 if pdefs.include?(:finally)
      self[param] = pdefs[:default]           if pdefs.include?(:default)
      self.env_vars param => pdefs[:env_var]  if pdefs.include?(:env_var)
      self.finally(&pdefs[:finally])          if pdefs.include?(:finally)
      self.finally(&block) if block
    end

    # performs type coercion, continues up the resolve! chain
    def resolve!
      resolve_types!
      super()
      self
    end

    # ensures required types are defined, continues up the validate! chain
    def validate!
      validate_requireds!
      super()
      true
    end

    # ===========================================================================
    #
    # Helpers for retrieving definitions
    #

    private
    def definitions
      @definitions ||= Hash.new{|hsh, key| hsh[key.to_sym] = Hash.new  }
    end
    public

    # Is the param defined?
    def has_definition?(param, attr=nil)
      if attr then definitions.has_key?(param.to_sym) && definitions[param].has_key?(attr)
      else         definitions.has_key?(param.to_sym) end
    end

    # all params with a value for the given aspect
    #
    # @example
    #   @config.define :has_description,  :description => 'desc 1', :foo => 'bar'
    #   #
    #   definition_of(:has_description)
    #   # => {:description => 'desc 1', :foo => 'bar'}
    #   definition_of(:has_description, :description)
    #   # => 'desc 1'
    #
    # @param aspect [Symbol] the aspect to list (:description, :type, :encrypted, etc.)
    # @return [Hash, Object]
    def definition_of(param, attr=nil)
      attr ? definitions[param.to_sym][attr] : definitions[param.to_sym]
    end

    # a hash holding every param with that aspect and its definition
    #
    # @example
    #   @config.define :has_description,      :description => 'desc 1'
    #   @config.define :also_has_description, :description => 'desc 2'
    #   @config.define :no_description,       :something_else => 'foo'
    #   #
    #   params_with(:description)
    #   # => { :has_description => 'desc 1', :also_has_description => 'desc 2' }
    #
    # @param aspect [Symbol] the aspect to list (:description, :type, :encrypted, etc.)
    # @return [Hash]
    def params_with(aspect)
      hsh = {}
      definitions.each do |param_name, param_def|
        next unless param_def.has_key?(aspect)
        hsh[param_name] = definition_of(param_name, aspect)
      end
      hsh
    end

    # ===========================================================================
    #
    # Type coercion
    #
    # Define types with
    #
    #   Settings.define :param, :type => Date
    #

    # Coerce all params with types defined to their proper form
    def resolve_types!
      params_with(:type).each do |param, type|
        val  = self[param]
        case
        when val.nil?            then val = nil
        when (type == :boolean)  then
          if ['false', false, 0, '0', ''].include?(val) then val = false else val = true end
        when (type == Array)
          if val.is_a?(String) then val = val.split(",") rescue nil ; end
        # for all following types, map blank/empty to nil
        when (val.respond_to?(:empty?) && val.empty?) then val = nil
        when (type == :filename) then val = File.expand_path(val)
        when (type == Float)     then val = val.to_f
        when (type == Integer)   then val = val.to_i
        when (type == Symbol)    then val = val.to_s.to_sym     rescue nil
        when (type == Regexp)    then val = Regexp.new(val)     rescue nil
        when ((val.to_s == 'now') && (type == Date))     then val = Date.today
        when ((val.to_s == 'now') && (type == DateTime)) then val = DateTime.now
        when ((val.to_s == 'now') && (type == Time))     then val = Time.now
        when [Date, Time, DateTime].include?(type)       then val = type.parse(val) rescue nil
        else true # nothing
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

    # Check that all required params are present.
    def validate_requireds!
      missing = []
      params_with(:required).each do |param, is_required|
        missing << param if self[param].nil? && is_required
      end
      return if missing.empty?
      raise "Missing values for: #{missing.map{|pn| d = definition_of(pn, :description) ; (d ? "#{pn} (#{d})" : pn.to_s) }.sort.join(", ")}"
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
      return(super) unless has_definition?(name)
      if setter && (args.size == 1)
        self[name] = args.first
      elsif (!setter) && args.empty?
        self[name]
      else super ; end
    end

  end

  # Define is included by default
  Param.class_eval do
    include Configliere::Define
  end
end
