require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'configliere/crypter'
include Configliere

describe "Crypter" do
  ENCRYPTED_FOO_VAL = "cc+Bp5jMUBHFCvPNZIfleeatB4IGaaXjVINl12HOpcs=\n".force_encoding("BINARY")
  FOO_VAL_IV = Base64.decode64(ENCRYPTED_FOO_VAL)[0..15]
  it "encrypts" do
    # Force the same initialization vector as used to prepare the test value
    @cipher = Crypter.send(:new_cipher, :encrypt, 'sekrit')
    Crypter.should_receive(:new_cipher).and_return(@cipher)
    @cipher.should_receive(:random_iv).and_return FOO_VAL_IV
    # OK so do the test now.
    Crypter.encrypt('foo_val', 'sekrit').force_encoding("BINARY").should == ENCRYPTED_FOO_VAL
  end
  it "decrypts" do
    Crypter.decrypt(ENCRYPTED_FOO_VAL, 'sekrit').should == 'foo_val'
  end
end
