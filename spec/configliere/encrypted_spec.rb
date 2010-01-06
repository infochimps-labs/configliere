require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
Configliere.use :encrypted

describe "Configliere::Encrypted" do
  before do
    @config = Configliere::Param.new :encrypted_param => 'encrypt_me', :normal_param => 'normal'
    @config.define :encrypted_param, :encrypted => true
    @config.encrypt_pass = 'pass'
  end

  describe 'defining encrypted params' do
    it 'is encrypted if defined with :encrypted => true' do
      @config.send(:encrypted_params).should include(:encrypted_param)
    end
    it 'is not encrypted if defined with :encrypted => false' do
      @config.define :another_param,   :encrypted => false
      @config.send(:encrypted_params).should_not include(:another_param)
      @config.send(:encrypted_params).should     include(:encrypted_param)
    end
    it 'is encrypted if not defined' do
      @config.send(:encrypted_params).should_not include(:missing_param)
    end
  end

  describe 'encrypting encryptable params' do
    it 'encrypts all params marked encrypted' do
      Configliere::Crypter.should_receive(:encrypt).with('encrypt_me', 'pass').and_return('ok_encrypted')
      @config.send(:export).should == { :normal_param => 'normal', :encrypted_param => 'ok_encrypted'}
    end
    it 'gets encrypted params successfully' do
      Configliere::Crypter.should_receive(:encrypt).with('encrypt_me', 'pass').and_return('ok_encrypted')
      @config.send(:encrypted_get, :encrypted_param).should == 'ok_encrypted'
    end
    it 'fails if no pass is set' do
      # create the config but don't set an encrypt_pass
      @config = Configliere::Param.new :encrypted_param => 'encrypt_me', :normal_param => 'normal'
      lambda{ @config.send(:encrypted_get, :encrypted_param) }.should raise_error('Blank encryption password!')
    end
  end

  describe 'decrypting encryptable params' do
    it 'decrypts all params marked encrypted' do
      @config.defaults :existing_param => 'existing'
      Configliere::Crypter.should_receive(:decrypt).with('decrypt_me', 'pass').and_return('ok_decrypted')
      hsh = { :normal_param => 'new_val', :encrypted_param => 'decrypt_me' }
      @config.send(:import, hsh).should == { :existing_param => 'existing', :normal_param => 'new_val', :encrypted_param => 'ok_decrypted'}
    end
  end

  describe 'loading a file' do
    before do
      @encrypted_str = "*\210BM\305\353\325\240.\226\212g\266f|\177\221\252k\263\363\260\031\263\371\035\257\024f+\001\350"
    end
    it 'encrypts' do
      Configliere::Crypter.should_receive(:encrypt).and_return(@encrypted_str)
      Configliere::ParamStore.should_receive(:write_yaml_file).with('/fake/file', :normal_param=>"normal", :encrypted_param => @encrypted_str)
      @config.save! '/fake/file'
    end
    it 'decrypts' do
      @hsh = { :loaded_param => "loaded", :encrypted_param => @encrypted_str }
      File.stub(:open)
      YAML.should_receive(:load).and_return(@hsh)
      @config.read 'file.yaml'
      @config.should == { :loaded_param => "loaded", :encrypted_param => 'decrypt_me', :normal_param => 'normal' }
    end
  end
end


