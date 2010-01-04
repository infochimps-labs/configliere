require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Thimblerig" do
  it "a simple load followed by save does the right thing" do
    test_hsh = { :cat => :hat, :lotion => :basket, :decrypted_foo => 'foo_val' }
    Thimblerig.save 'sekrit', test_hsh
    result_thimble = Thimblerig.load('sekrit')
    result_thimble.to_decrypted.should == test_hsh
  end

  it "The simple load / store accept a thimble_name" do
    test_hsh = { :cat => :hat, :lotion => :basket, :decrypted_foo => 'foo_val' }
    Thimblerig.save 'sekrit', test_hsh.merge(:thimble_name => :bob)
    result_thimble = Thimblerig.load('sekrit', :thimble_name => :bob)
    result_thimble.to_decrypted.should == test_hsh
    Thimblerig::ThimbleStore.new().handles.should include(:bob)
  end

end
