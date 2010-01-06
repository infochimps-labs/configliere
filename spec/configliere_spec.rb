require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Configliere" do
  it 'creates a new param on new' do
    mock_param = 'mock_param'
    Configliere::Param.should_receive(:new).with(:this => :that).and_return(mock_param)
    Configliere.new(:this => :that).should == mock_param
  end
  it 'creates a global variable Settings' do
    Settings.class.should == Configliere::Param
  end
  it 'creates a glocal method Settings' do
    Settings.should_receive(:defaults).with(:foo => :bar)
    Settings(:foo => :bar)
  end

  it 'requires modules with use' do
    lambda{ Configliere.use(:param, :foo) }.should raise_error(LoadError, 'no such file to load -- configliere/foo')
  end

end
