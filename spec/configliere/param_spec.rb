require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Configliere::Param" do
  before do
    @config = Configliere::Param.new
  end

  describe '#defaults' do
    it 'merges new params' do
      @config.defaults :hat => :cat, :basket => :lotion, :moon => { :man => :smiling }
      @config.defaults :basket => :tasket, :moon => { :cow => :jumping }
      @config.should == { :hat => :cat, :basket => :tasket, :moon => { :man => :smiling, :cow => :jumping } }
    end
  end

  describe 'setting vals' do
    it 'deep-sets dotted vals' do
      @config.defaults :hat => :cat, :basket => :lotion, :moon => { :man => :smiling }
      @config['moon.man'] = :cheesy
      @config[:moon][:man].should == :cheesy
      @config['moon.cheese.type'] = :tilsit
      @config[:moon][:cheese][:type].should == :tilsit
    end
    it 'deep-gets dotted vals' do
      hsh = { :hat => :cat, :basket => :lotion, :moon => { :man => :smiling, :cheese => {:type => :tilsit} } }
      @config.defaults hsh
      @config['moon.man'].should == :smiling
      @config['moon.cheese.type'].should == :tilsit
      @config['moon.cheese.smell'].should be_nil
      @config['moon.non.existent.interim.values'].should be_nil
      @config['moon.non'].should be_nil
      lambda{ @config['hat.cat'] }.should raise_error(NoMethodError, 'undefined method `[]\' for :cat:Symbol')
      @config.should == hsh # shouldn't change from reading
    end
  end

  # before do
  #   @param = Configliere::Param.new("sekrit", :this => :that)
  # end
  # it "uses its decrypt_pass" do
  #   @param.decrypt_pass.should == "sekrit"
  # end
  # it "behaves like a hash" do
  #   @param.should include(:this)
  #   @param[:this].should == :that
  #   @param[:this] = :the_other
  #   @param[:this].should == :the_other
  # end
  # it "merges" do
  #   @param.merge! :cat => :hat
  #   @param.should == { :this => :that, :cat => :hat }
  # end
  # ENCRYPTED_FOO_VAL = "q\317\201\247\230\314P\021\305\n\363\315d\207\345y\346\255\a\202\006i\245\343T\203e\327a\316\245\313"
  # it "accepts encrypted values" do
  #   encrypted_foo = ENCRYPTED_FOO_VAL
  #   @param[:encrypted_foo] = encrypted_foo
  #   @param[:decrypted_foo].should == 'foo_val'
  # end
  # it "accepts decrypted values" do
  #   Configliere::Crypter.should_receive(:encrypt).with('foo_val', 'sekrit').and_return(ENCRYPTED_FOO_VAL)
  #   @param[:decrypted_foo] = 'foo_val'
  #   @param[:encrypted_foo].should == ENCRYPTED_FOO_VAL
  #   @param[:decrypted_foo].should == 'foo_val'
  # end
end
