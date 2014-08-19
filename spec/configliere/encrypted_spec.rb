require 'spec_helper'

module Configliere ; module Crypter ; CIPHER_TYPE = 'aes-128-cbc' ; end ; end

describe "Configliere::Encrypted", :if => check_openssl do
  require 'configliere/crypter'

  subject{ Configliere::Param.new :secret => 'encrypt_me', :normal_param => 'normal' }

  before do
    subject.use :encrypted
    subject.define :secret, :encrypted => true
    subject[:encrypt_pass] = 'pass'
  end

  if    Configliere::Crypter::CIPHER_TYPE == 'aes-256-cbc'
    let(:encrypted_str)    { "KohCTcXr1aAulopntmZ8f5Gqa7PzsBmz+R2vFGYrAeg=\n" }
    let(:encrypted_foo_val){ "cc+Bp5jMUBHFCvPNZIfleeatB4IGaaXjVINl12HOpcs=\n" }
  elsif Configliere::Crypter::CIPHER_TYPE == 'aes-128-cbc'
    let(:encrypted_str)    { "mHse6HRTANh8JpIfIuyANQ8b2rXAf0+/3pzQnYsd8LE=\n" }
    let(:encrypted_foo_val){ "cc+Bp5jMUBHFCvPNZIfleZYRoDmLK1LSxPkAMemhDTQ=\n" }
  else
    warn "Can't make test strings for #{Configliere::Crypter::CIPHER_TYPE} cipher"
  end

  let(:foo_val_iv){  Base64.decode64(encrypted_foo_val)[0..15] }

  context Configliere::Crypter do
    it "encrypts" do
      # Force the same initialization vector as used to prepare the test value
      cipher = Configliere::Crypter.send(:new_cipher, :encrypt, 'sekrit')
      Configliere::Crypter.should_receive(:new_cipher).and_return(cipher)
      cipher.should_receive(:random_iv).and_return foo_val_iv
      # OK so do the test now.
      Configliere::Crypter.encrypt('foo_val', 'sekrit').should == encrypted_foo_val
    end

    it "decrypts" do
      Configliere::Crypter.decrypt(encrypted_foo_val, 'sekrit').should == 'foo_val'
    end
  end

  context 'defines encrypted params' do
    it 'with :encrypted => true' do
      subject.send(:encrypted_params).should include(:secret)
    end

    it 'but not if :encrypted => false' do
      subject.define :another_param,   :encrypted => false
      subject.send(:encrypted_params).should_not include(:another_param)
      subject.send(:encrypted_params).should     include(:secret)
    end

    it 'only if :encrypted is given' do
      subject.send(:encrypted_params).should_not include(:missing_param)
    end
  end

  context 'the encrypt_pass' do
    it 'will take an environment variable if any exists' do
      subject[:encrypt_pass] = nil
      ENV.should_receive(:[]).with('ENCRYPT_PASS').at_least(:once).and_return('monkey')
      subject.send(:export)
      subject.send(:instance_variable_get, "@encrypt_pass").should == 'monkey'
    end

    it 'will take an internal value if given, and remove it' do
      subject[:encrypt_pass] = 'hello'
      subject.send(:export)
      subject.send(:instance_variable_get, "@encrypt_pass").should == 'hello'
      subject[:encrypt_pass].should be_nil
      subject.has_key?(:encrypt_pass).should_not be_true
    end
  end

  context 'encrypts' do
    it 'all params with :encrypted' do
      Configliere::Crypter.should_receive(:encrypt).with('encrypt_me', 'pass').and_return('ok_encrypted')
      subject.send(:export).should == { :normal_param => 'normal', :encrypted_secret => 'ok_encrypted'}
    end

    it 'fails unless encrypt_pass is set' do
      # create the config but don't set an encrypt_pass
      subject = Configliere::Param.new :secret => 'encrypt_me', :normal_param => 'normal'
      subject.use :encrypted
      expect{ subject.send(:encrypted, subject[:secret]) }.to raise_error('Missing encryption password!')
    end
  end

  context 'decrypts' do
    it 'all params marked encrypted' do
      subject.delete   :secret
      subject.defaults :encrypted_secret => 'decrypt_me'
      Configliere::Crypter.should_receive(:decrypt).with('decrypt_me', 'pass').and_return('ok_decrypted')
      subject.send(:resolve_encrypted!)
      subject.should == { :normal_param => 'normal', :secret => 'ok_decrypted' }
    end
  end

  context 'loading a file' do
    it 'encrypts' do
      Configliere::Crypter.should_receive(:encrypt).and_return(encrypted_str)
      FileUtils.stub(:mkdir_p)
      File.should_receive(:open).and_yield([])
      YAML.should_receive(:dump).with({ :normal_param => "normal", :encrypted_secret => encrypted_str })
      subject.save! '/fake/file'
    end

    it 'decrypts' do
      hsh = { :loaded_param => "loaded", :encrypted_secret => encrypted_str }
      File.stub(:open)
      YAML.should_receive(:load).and_return(hsh)
      subject.read 'file.yaml'
      subject.resolve!
      subject.should_not include(:encrypted_secret)
      subject.should == { :loaded_param => "loaded", :secret => 'decrypt_me', :normal_param => 'normal' }
    end
  end

  context '#resolve!' do
    it 'calls super and returns self' do
      Configliere::ParamParent.class_eval do def resolve!() dummy ; end ; end
      subject.should_receive(:dummy)
      subject.resolve!.should equal(subject)
      Configliere::ParamParent.class_eval do def resolve!() self ; end ; end
    end

    it 'removes the encrypt_pass from sight' do
      subject[:encrypt_pass] = 'hello'
      subject.resolve!
      subject.send(:instance_variable_get, "@encrypt_pass").should == 'hello'
      subject[:encrypt_pass].should be_nil
      subject.has_key?(:encrypt_pass).should_not be_true
    end
  end

  context '#validate!' do
    it 'calls super and returns self' do
      Configliere::ParamParent.class_eval do def validate!() dummy ; end ; end
      subject.should_receive(:dummy)
      subject.validate!.should equal(subject)
      Configliere::ParamParent.class_eval do def validate!() self ; end ; end
    end
  end
end
