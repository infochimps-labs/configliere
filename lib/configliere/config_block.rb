module Configliere
  #
  # ConfigBlock lets you use pure ruby to change and define settings.  Call
  # +#finally+ with a block of code to be run after all other settings are in
  # place.
  #
  #     Settings.finally{|c| c.your_mom[:college] = 'went' unless (! c.mom_jokes_allowed) }
  #
  module ConfigBlock
    #
    # Define a block of code to run after all other settings are in place.
    #
    # @param &block each +finally+ block is called once, in the order it was
    #   defined, when the resolve! method is invoked. +config_block+ resolution
    #   is guaranteed to run last in the resolve chain, right before validation.
    #
    # @example
    #   Settings.finally do |c|
    #     c.dest_time = (Time.now + 60) if c.username == 'einstein'
    #     # you can use hash syntax too
    #     c[:dest_time] = (Time.now + 60) if c[:username] == 'einstein'
    #   end
    #   # ...
    #   # after rest of setup:
    #   Settings.resolve!
    #
    def finally &block
      self.final_blocks << block if block
    end

    # Processing to reconcile all options
    #
    # The resolve! for config_block is made to run last of all in the +resolve!+
    # chain, and runs each +finally+ block in the order it was defined.
    def resolve!
      super
      resolve_finally_blocks!
      self
    end

  protected
    # Config blocks to be executed at end of resolution (just before validation)
    attr_accessor :final_blocks
    def final_blocks
      @final_blocks ||= []
    end

    # call each +finally+ config block in the order it was defined
    def resolve_finally_blocks!
      final_blocks.each do |block|
        (block.arity == 1) ? block.call(self) : block.call()
      end
    end
  end

  Param.class_eval do
    include Configliere::ConfigBlock
  end
end
