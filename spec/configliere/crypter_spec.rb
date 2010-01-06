require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'configliere/crypter'
include Configliere

describe "Crypter" do
  ENCRYPTED_FOO_VAL = "q\317\201\247\230\314P\021\305\n\363\315d\207\345y\346\255\a\202\006i\245\343T\203e\327a\316\245\313"
  it "encrypts" do
    # Force the same initialization vector as used to prepare the test value
    @cipher = Crypter.send(:new_cipher, :encrypt, 'sekrit')
    Crypter.should_receive(:new_cipher).and_return(@cipher)
    @cipher.should_receive(:random_iv).and_return ENCRYPTED_FOO_VAL[0..15]
    # OK so do the test now.
    Crypter.encrypt('foo_val', 'sekrit').should == ENCRYPTED_FOO_VAL
  end
  it "decrypts" do
    Crypter.decrypt(ENCRYPTED_FOO_VAL, 'sekrit').should == 'foo_val'
  end
end
