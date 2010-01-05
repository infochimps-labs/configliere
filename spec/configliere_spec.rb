require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Configliere" do
  it "a simple load followed by save does the right thing" do
    test_hsh = { :cat => :hat, :lotion => :basket, :decrypted_foo => 'foo_val' }
    Configliere.save 'sekrit', test_hsh
    result_param = Configliere.load('sekrit')
    result_param.to_decrypted.should == test_hsh
  end

  it "The simple load / store accept a param_name" do
    test_hsh = { :cat => :hat, :lotion => :basket, :decrypted_foo => 'foo_val' }
    Configliere.save 'sekrit', test_hsh.merge(:param_name => :bob)
    result_param = Configliere.load('sekrit', :param_name => :bob)
    result_param.to_decrypted.should == test_hsh
    Configliere::ParamStore.new().handles.should include(:bob)
  end

end
