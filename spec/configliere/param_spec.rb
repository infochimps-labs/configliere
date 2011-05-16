require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Configliere::Param" do
  before do
    @config = Configliere::Param.new :hat => :cat, :basket => :lotion, :moon => { :man => :smiling }
  end

  describe 'calling #defaults' do
    it 'deep_merges new params' do
      @config.defaults :basket => :tasket, :moon => { :cow => :jumping }
      @config.should == { :hat => :cat, :basket => :tasket, :moon => { :man => :smiling, :cow => :jumping } }
    end
    it 'returns self, to allow chaining' do
      obj = @config.defaults(:basket => :ball)
      obj.should equal(@config)
    end
  end

  describe 'adding plugins with #use' do
    before do
      Configliere.should_receive(:use).with(:foobar)
    end
    it 'requires the corresponding library' do
      obj = @config.use(:foobar)
    end
    it 'returns self, to allow chaining' do
      obj = @config.use(:foobar)
      obj.should equal(@config)
    end
    it 'invokes the on_use handler' do
      Configliere::Param.on_use(:foobar) do
        method_on_config(:param)
      end
      @config.should_receive(:method_on_config).with(:param)
      @config.use(:foobar)
    end
  end

  describe '#resolve!' do
    it 'calls super and returns self' do
      Configliere::ParamParent.class_eval do def resolve!() dummy ; end ; end
      @config.should_receive(:dummy)
      @config.resolve!.should equal(@config)
      Configliere::ParamParent.class_eval do def resolve!() self ; end ; end
    end
  end

end
