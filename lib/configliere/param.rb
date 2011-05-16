module Configliere
  #
  # We want to be able to call super() on these methods in all included models,
  # so we define them in this parent shim class.
  #
  class ParamParent < DeepHash
    # default export method: dup of self
    def export
      dup.tap{|hsh| hsh.each{|k,v| hsh[k] = v.respond_to?(:export) ? v.export : v } }
    end
    # terminate resolution chain
    # @returns self
    def resolve!
      self
    end
    # terminate validation chain.
    # @returns self
    def validate!
      self
    end
  end

  #
  # Hash of fields to store.
  #
  # Any field name beginning with 'decrypted_' automatically creates a
  # counterpart 'encrypted_' field using the encrypt_pass.
  #
  class Param < Configliere::ParamParent

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
    # @returns self
    def defaults hsh
      deep_merge! hsh
      self
    end

    # Finalize and validate params. All include'd modules and subclasses *must* call super()
    # @returns self
    def resolve!
      super()
      validate!
      self
    end

    # Check that all defined params are valid. All include'd modules and subclasses *must*call super()
    # @returns self
    def validate!
      super()
      self
    end

    def use *mws
      hsh = mws.pop if mws.last.is_a?(Hash)
      Configliere.use(*mws)
      mws.each do |mw|
        if blk = USE_HANDLERS[mw]
          instance_eval(&blk)
        end
      end
      self.deep_merge!(hsh) if hsh
      self
    end

    # @internal
    USE_HANDLERS = {}
    # Block executed when use is invoked
    def self.on_use mw, &block
      USE_HANDLERS[mw] = block
    end

  end
end
