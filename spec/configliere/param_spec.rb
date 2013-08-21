require 'spec_helper'

describe Configliere::Param do

  subject{ described_class.new(:hat => :cat, :basket => :lotion, :moon => { :man => :smiling }) }

  describe 'calling #defaults' do
    it 'deep_merges new params' do
      subject.defaults :basket => :tasket, :moon => { :cow => :jumping }
      subject.should == { :hat => :cat, :basket => :tasket, :moon => { :man => :smiling, :cow => :jumping } }
    end

    it 'returns self, to allow chaining' do
      return_value = subject.defaults(:basket => :ball)
      return_value.should equal(subject)
    end
  end

  describe 'adding plugins with #use' do
    before do
      Configliere.should_receive(:use).with(:foobar)
    end

    it 'requires the corresponding library' do
      subject.use(:foobar)
    end

    it 'returns self, to allow chaining' do
      return_value = subject.use(:foobar)
      return_value.should equal(subject)
    end

    it 'invokes the on_use handler' do
      described_class.on_use(:foobar) do
        method_on_config(:param)
      end
      subject.should_receive(:method_on_config).with(:param)
      subject.use(:foobar)
    end
  end

  describe '#resolve!' do
    it 'calls super and returns self' do
      Configliere::ParamParent.class_eval do def resolve!() dummy ; end ; end
      subject.should_receive(:dummy)
      subject.resolve!.should equal(subject)
      Configliere::ParamParent.class_eval do def resolve!() self ; end ; end
    end
  end
end
