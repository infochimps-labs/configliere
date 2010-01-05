require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Configliere::Param" do
  before do
    @param = Configliere::Param.new("sekrit", :this => :that)
  end
  it "uses its decrypt_pass" do
    @param.decrypt_pass.should == "sekrit"
  end
  it "behaves like a hash" do
    @param.should include(:this)
    @param[:this].should == :that
    @param[:this] = :the_other
    @param[:this].should == :the_other
  end
  it "merges" do
    @param.merge! :cat => :hat
    @param.should == { :this => :that, :cat => :hat }
  end
  ENCRYPTED_FOO_VAL = "q\317\201\247\230\314P\021\305\n\363\315d\207\345y\346\255\a\202\006i\245\343T\203e\327a\316\245\313"
  it "accepts encrypted values" do
    encrypted_foo = ENCRYPTED_FOO_VAL
    @param[:encrypted_foo] = encrypted_foo
    @param[:decrypted_foo].should == 'foo_val'
  end
  it "accepts decrypted values" do
    Configliere::Crypter.should_receive(:encrypt).with('foo_val', 'sekrit').and_return(ENCRYPTED_FOO_VAL)
    @param[:decrypted_foo] = 'foo_val'
    @param[:encrypted_foo].should == ENCRYPTED_FOO_VAL
    @param[:decrypted_foo].should == 'foo_val'
  end

end
