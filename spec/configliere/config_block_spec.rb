require 'spec_helper'
Configliere.use :config_block

describe Configliere::ConfigBlock do

  subject{ Configliere::Param.new :normal_param => 'normal' }

  describe 'resolving' do
    it 'runs blocks' do
      @block_watcher = 'watcher'
      # @block_watcher.should_receive(:fnord).with(@config)
      @block_watcher.should_receive(:fnord)
      subject.finally{|arg| @block_watcher.fnord(arg) }
      subject.resolve!
    end
    it 'resolves blocks last' do
      Configliere.use :config_block, :encrypted
      subject.should_receive(:resolve_types!).ordered
      subject.should_receive(:resolve_finally_blocks!).ordered
      subject.resolve!
    end

    it 'calls super and returns self' do
      Configliere::ParamParent.class_eval do def resolve!() dummy ; end ; end
      subject.should_receive(:dummy)
      subject.resolve!.should equal(subject)
      Configliere::ParamParent.class_eval do def resolve!() self ; end ; end
    end
  end

  describe '#validate!' do
    it 'calls super and returns self' do
      Configliere::ParamParent.class_eval do def validate!() dummy ; end ; end
      subject.should_receive(:dummy)
      subject.validate!.should equal(subject)
      Configliere::ParamParent.class_eval do def validate!() self ; end ; end
    end
  end
end
