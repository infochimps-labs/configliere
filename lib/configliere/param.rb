require 'configliere/core_ext/sash.rb'
module Configliere
  class ParamParent < ::Hash
    # default export method: self
    def export
      to_hash
    end
    # terminate resolution chain
    def resolve!
    end
    # terminate validation chain
    def validate!
    end
  end

  #
  # Hash of fields to store.
  #
  # Any field name beginning with 'decrypted_' automatically creates a
  # counterpart 'encrypted_' field using the encrypt_pass.
  #
  class Param < Configliere::ParamParent

    # @param constructor<Object>
    #   The default value for the mash. Defaults to an empty hash.
    #
    # @details [Alternatives]
    #   If constructor is a Hash, a new mash will be created based on the keys of
    #   the hash and no default value will be set.
    def initialize(constructor = {})
      if constructor.is_a?(Hash)
        super()
        update(constructor) unless constructor.empty?
      else
        super(constructor)
      end
    end

    # @return [Hash] The mash as a Hash with string keys.
    def to_hash
      Hash.new(default).merge(self)
    end

    #
    # Incorporates the given settings.
    # alias for deep_merge!
    # Existing values not given in the hash
    #
    # @param hsh the defaults to set.
    #
    # @example
    #    Settings.defaults :hat => :cat, :basket => :lotion, :moon => { :man => :smiling }
    #    Settings.defaults :basket => :tasket, :moon => { :cow => :smiling }
    #    Config  #=> { :hat => :cat, :basket => :tasket, :moon => { :man => :smiling, :cow => :jumping } }
    #
    def defaults hsh
      deep_merge! hsh
    end

    # Finalize and validate params
    def resolve!
      super()
      validate!
    end
    # Check that all defined params are valid
    def validate!
      super()
    end

    def []= param, val
      if param =~ /\./
        return deep_set( *(convert_key(param) | [val]) )
      else
        super param, val
      end
    end

    def [] param
      if param =~ /\./
        return deep_get( *convert_key(param) )
      else
        super param
      end
    end

    def delete param
      if param =~ /\./
        return deep_delete( *convert_key(param) )
      else
        super param
      end
    end

    def use *args
      hsh = args.pop if args.last.is_a?(Hash)
      Configliere.use(*args)
      self.deep_merge!(hsh) unless hsh.nil?
    end

  protected
    # @param key<Object> The key to convert.
    #
    # @param [Object]
    #   The converted key. A dotted param ('moon.cheese.type') becomes
    #   an array of sequential keys for deep_set and deep_get
    #
    # @api private
    def convert_key dotted
      dotted.to_s.split(".").map{|key| key.to_sym }
    end

  end
end
