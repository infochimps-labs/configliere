require 'spec_helper'
Configliere.use :config_block

describe "Configliere::ConfigBlock" do
  before do
    @config = Configliere::Param.new :normal_param => 'normal'
  end

  describe 'resolving' do
    it 'runs blocks' do
      @block_watcher = 'watcher'
      # @block_watcher.should_receive(:fnord).with(@config)
      @block_watcher.should_receive(:fnord)
      @config.finally{|arg| @block_watcher.fnord(arg) }
      @config.resolve!
    end
    it 'resolves blocks last' do
      Configliere.use :config_block, :encrypted
      @config.should_receive(:resolve_types!).ordered
      @config.should_receive(:resolve_finally_blocks!).ordered
      @config.resolve!
    end

    it 'calls super and returns self' do
      Configliere::ParamParent.class_eval do def resolve!() dummy ; end ; end
      @config.should_receive(:dummy)
      @config.resolve!.should equal(@config)
      Configliere::ParamParent.class_eval do def resolve!() self ; end ; end
    end
  end

  describe '#validate!' do
    it 'calls super and returns self' do
      Configliere::ParamParent.class_eval do def validate!() dummy ; end ; end
      @config.should_receive(:dummy)
      @config.validate!.should equal(@config)
      Configliere::ParamParent.class_eval do def validate!() self ; end ; end
    end
  end

end
