require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Crypter", :if => load_sketchy_lib('openssl', /openssl/)  do
  #
  let(:encrypted_foo_val){ "cc+Bp5jMUBHFCvPNZIfleeatB4IGaaXjVINl12HOpcs=\n" }
  # ENCRYPTED_FOO_VAL.force_encoding("BINARY") if ENCRYPTED_FOO_VAL.respond_to?(:force_encoding)
  let(:foo_val_iv){  Base64.decode64(encrypted_foo_val)[0..15] }

  it "encrypts" do
    # Force the same initialization vector as used to prepare the test value
    @cipher = Configliere::Crypter.send(:new_cipher, :encrypt, 'sekrit')
    Configliere::Crypter.should_receive(:new_cipher).and_return(@cipher)
    @cipher.should_receive(:random_iv).and_return foo_val_iv
    # OK so do the test now.
    Configliere::Crypter.encrypt('foo_val', 'sekrit').should == encrypted_foo_val
  end

  it "decrypts" do
    Configliere::Crypter.decrypt(encrypted_foo_val, 'sekrit').should == 'foo_val'
  end
end
