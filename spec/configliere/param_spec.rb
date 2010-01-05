require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Thimblerig::Thimble" do
  before do
    @thimble = Thimblerig::Thimble.new("sekrit", :this => :that)
  end
  it "uses its thimble_key" do
    @thimble.thimble_key.should == "sekrit"
  end
  it "behaves like a hash" do
    @thimble.should include(:this)
    @thimble[:this].should == :that
    @thimble[:this] = :the_other
    @thimble[:this].should == :the_other
  end
  it "merges" do
    @thimble.merge! :cat => :hat
    @thimble.should == { :this => :that, :cat => :hat }
  end
  ENCRYPTED_FOO_VAL = "q\317\201\247\230\314P\021\305\n\363\315d\207\345y\346\255\a\202\006i\245\343T\203e\327a\316\245\313"
  it "accepts encrypted values" do
    encrypted_foo = ENCRYPTED_FOO_VAL
    @thimble[:encrypted_foo] = encrypted_foo
    @thimble[:decrypted_foo].should == 'foo_val'
  end
  it "accepts decrypted values" do
    Thimblerig::Crypter.should_receive(:encrypt).with('foo_val', 'sekrit').and_return(ENCRYPTED_FOO_VAL)
    @thimble[:decrypted_foo] = 'foo_val'
    @thimble[:encrypted_foo].should == ENCRYPTED_FOO_VAL
    @thimble[:decrypted_foo].should == 'foo_val'
  end

end
