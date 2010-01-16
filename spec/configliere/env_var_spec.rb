require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
Configliere.use :env_var

describe "Configliere::EnvVar" do
  before do
    @config = Configliere::Param.new
  end

  describe 'loads environment variables' do
    it 'loads a simple value into the corresponding symbolic key' do
      ENV.should_receive(:[]).with('HOME').and_return('/fake/path')
      @config.env_vars 'HOME'
      @config[:home].should == '/fake/path'
    end
    it 'loads a hash into the individual params' do
      ENV.should_receive(:[]).with('HOME').and_return('/fake/path')
      ENV.should_receive(:[]).with('POWER_SUPPLY').and_return('1.21 jigawatts')
      @config.env_vars :home => 'HOME', 'delorean.power_supply' => 'POWER_SUPPLY'
      @config[:home].should == '/fake/path'
      @config[:delorean][:power_supply].should == '1.21 jigawatts'
    end
  end
end

