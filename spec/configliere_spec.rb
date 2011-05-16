require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Configliere" do
  it 'creates a global variable Settings, for universality' do
    Settings.class.should == Configliere::Param
  end
  it 'creates a global method Settings, so you can say Settings(:foo => :bar)' do
    Settings.should_receive(:defaults).with(:foo => :bar)
    Settings(:foo => :bar)
  end

  it 'requires corresponding plugins when you call use' do
    lambda{ Configliere.use(:param, :foo) }.should raise_error(LoadError, 'no such file to load -- configliere/foo')
  end
end
