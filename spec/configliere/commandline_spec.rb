require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'configliere/commandline'

describe "Configliere::Commandline" do
  before do
    @config = Configliere::Param.new :param_1 => 'val 1', :cat => :hat
  end

  it 'handles --param=val pairs' do
    ::ARGV.replace ['--my_param=my_val']
    @config.resolve!
    @config.should == { :my_param => 'my_val', :param_1 => 'val 1', :cat => :hat}
  end
  it 'handles --dotted.param.name=val pairs' do
    ::ARGV.replace ['--dotted.param.name=my_val']
    @config.resolve!
    @config.rest.should be_empty
    @config.should == { :dotted => { :param => { :name => 'my_val' }}, :param_1 => 'val 1', :cat => :hat}
  end
  it 'handles --dashed-param-name=val pairs' do
    ::ARGV.replace ['--dashed-param-name=my_val']
    @config.resolve!
    @config.rest.should be_empty
    @config.should == { :dashed => { :param => { :name => 'my_val' }}, :param_1 => 'val 1', :cat => :hat}
  end
  it 'uses the last-seen of the commandline values' do
    ::ARGV.replace ['--param_1=A', '--param_1=B']
    @config.resolve!
    @config.rest.should be_empty
    @config.should == { :param_1 => 'B', :cat => :hat}
  end
  it 'sets a bare parameter (no "=") to true' do
    ::ARGV.replace ['--param_1', '--deep.param']
    @config.resolve!
    @config.rest.should be_empty
    @config.should == { :param_1 => true, :deep => { :param => true }, :cat => :hat}
  end
  it 'sets an explicit blank to nil' do
    ::ARGV.replace ['--param_1=', '--deep.param=']
    @config.resolve!
    @config.should == { :param_1 => nil, :deep => { :param => nil }, :cat => :hat}
  end

  it 'saves non --param args into rest' do
    ::ARGV.replace ['--param_1', 'file1', 'file2']
    @config.resolve!
    @config.should == { :param_1 => true, :cat => :hat}
    @config.rest.should == ['file1', 'file2']
  end

  it 'stops processing on "--"' do
    ::ARGV.replace ['--param_1=A', '--', '--param_1=B']
    @config.resolve!
    @config.rest.should == ['--param_1=B']
    @config.should == { :param_1 => 'A', :cat => :hat}
  end

  after do
    ::ARGV.replace []
  end
end

