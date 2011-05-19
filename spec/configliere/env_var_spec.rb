require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Configliere::EnvVar" do
  before do
    @config = Configliere::Param.new
    @config.use :env_var
  end

  describe 'environment variables can be defined' do
    it 'with #env_vars, a simple value like "HOME" uses the corresponding key :home' do
      ENV.should_receive(:[]).with('HOME').and_return('/fake/path')
      @config.env_vars 'HOME'
      @config[:home].should == '/fake/path'
    end

    it 'with #env_vars, a hash pairs environment variables into the individual params' do
      ENV.should_receive(:[]).with('HOME').and_return('/fake/path')
      ENV.should_receive(:[]).with('POWER_SUPPLY').and_return('1.21 jigawatts')
      @config.env_vars :home => 'HOME', 'delorean.power_supply' => 'POWER_SUPPLY'
      @config[:home].should == '/fake/path'
      @config[:delorean][:power_supply].should == '1.21 jigawatts'
    end

    it 'with #define' do
      ENV.should_receive(:[]).with('HOME').and_return('/fake/path')
      ENV.should_receive(:[]).with('POWER_SUPPLY').and_return('1.21 jigawatts')
      @config.define :home, :env_var => 'HOME'
      @config.define 'delorean.power_supply', :env_var => 'POWER_SUPPLY'
      @config[:home].should == '/fake/path'
      @config[:delorean][:power_supply].should == '1.21 jigawatts'
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

  describe '#validate!' do
    it 'calls super and returns self' do
      Configliere::ParamParent.class_eval do def validate!() dummy ; end ; end
      @config.should_receive(:dummy)
      @config.validate!.should equal(@config)
      Configliere::ParamParent.class_eval do def validate!() self ; end ; end
    end
  end

end

