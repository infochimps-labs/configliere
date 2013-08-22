require 'spec_helper'
require 'configliere/env_var'

describe Configliere::EnvVar do
  
  subject{ Configliere::Param.new.use :env_var }

  context 'environment variables can be defined' do
    it 'with #env_vars, a simple value like "HOME" uses the corresponding key :home' do
      ENV.should_receive(:[]).with('HOME').and_return('/fake/path')
      subject.env_vars 'HOME'
      subject[:home].should == '/fake/path'
    end

    it 'with #env_vars, a hash pairs environment variables into the individual params' do
      ENV.should_receive(:[]).with('HOME').and_return('/fake/path')
      ENV.should_receive(:[]).with('POWER_SUPPLY').and_return('1.21 jigawatts')
      subject.env_vars :home => 'HOME', 'delorean.power_supply' => 'POWER_SUPPLY'
      subject[:home].should == '/fake/path'
      subject[:delorean][:power_supply].should == '1.21 jigawatts'
    end

    it 'with #define' do
      ENV.should_receive(:[]).with('HOME').and_return('/fake/path')
      ENV.should_receive(:[]).with('POWER_SUPPLY').and_return('1.21 jigawatts')
      subject.define :home, :env_var => 'HOME'
      subject.define 'delorean.power_supply', :env_var => 'POWER_SUPPLY'
      subject[:home].should == '/fake/path'
      subject[:delorean][:power_supply].should == '1.21 jigawatts'
    end
  end

  context '#resolve!' do
    it 'calls super and returns self' do
      Configliere::ParamParent.class_eval do def resolve!() dummy ; end ; end
      subject.should_receive(:dummy)
      subject.resolve!.should equal(subject)
      Configliere::ParamParent.class_eval do def resolve!() self ; end ; end
    end
  end

  context '#validate!' do
    it 'calls super and returns self' do
      Configliere::ParamParent.class_eval do def validate!() dummy ; end ; end
      subject.should_receive(:dummy)
      subject.validate!.should equal(subject)
      Configliere::ParamParent.class_eval do def validate!() self ; end ; end
    end
  end
end
