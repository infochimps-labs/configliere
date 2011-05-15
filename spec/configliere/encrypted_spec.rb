require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
Configliere.use :encrypted

describe "Configliere::Encrypted" do
  before do
    @config = Configliere::Param.new :secret => 'encrypt_me', :normal_param => 'normal'
    @config.define :secret, :encrypted => true
    @config.encrypt_pass = 'pass'
  end

  describe 'defining encrypted params' do
    it 'is encrypted if defined with :encrypted => true' do
      @config.send(:encrypted_params).should include(:secret)
    end
    it 'is not encrypted if defined with :encrypted => false' do
      @config.define :another_param,   :encrypted => false
      @config.send(:encrypted_params).should_not include(:another_param)
      @config.send(:encrypted_params).should     include(:secret)
    end
    it 'is encrypted if not defined' do
      @config.send(:encrypted_params).should_not include(:missing_param)
    end
  end

  describe 'encrypting encryptable params' do
    it 'encrypts all params marked encrypted' do
      Configliere::Crypter.should_receive(:encrypt).with('encrypt_me', 'pass').and_return('ok_encrypted')
      @config.send(:export).should == { :normal_param => 'normal', :encrypted_secret => 'ok_encrypted'}
    end
    it 'gets encrypted params successfully' do
      Configliere::Crypter.should_receive(:encrypt).with('encrypt_me', 'pass').and_return('ok_encrypted')
      @config.send(:encrypted, @config[:secret]).should == 'ok_encrypted'
    end
    it 'fails if no pass is set' do
      # create the config but don't set an encrypt_pass
      @config = Configliere::Param.new :secret => 'encrypt_me', :normal_param => 'normal'
      lambda{ @config.send(:encrypted, @config[:secret]) }.should raise_error('Missing encryption password!')
    end
  end

  describe 'decrypting encryptable params' do
    it 'decrypts all params marked encrypted' do
      @config.delete   :secret
      @config.defaults :encrypted_secret => 'decrypt_me'
      Configliere::Crypter.should_receive(:decrypt).with('decrypt_me', 'pass').and_return('ok_decrypted')
      @config.send(:resolve_encrypted!)
      @config.should == { :normal_param => 'normal', :secret => 'ok_decrypted' }
    end
  end

  describe 'loading a file' do
    before do
      @encrypted_str = "KohCTcXr1aAulopntmZ8f5Gqa7PzsBmz+R2vFGYrAeg=\n"
    end
    it 'encrypts' do
      Configliere::Crypter.should_receive(:encrypt).and_return(@encrypted_str)
      Configliere::ConfigFile.should_receive(:write_yaml_file).with('/fake/file', :normal_param=>"normal", :encrypted_secret => @encrypted_str)
      @config.save! '/fake/file'
    end
    it 'decrypts' do
      @hsh = { :loaded_param => "loaded", :encrypted_secret => @encrypted_str }
      File.stub(:open)
      YAML.should_receive(:load).and_return(@hsh)
      @config.read 'file.yaml'
      @config.resolve!
      @config.should_not include(:encrypted_secret)
      @config.should == { :loaded_param => "loaded", :secret => 'decrypt_me', :normal_param => 'normal' }
    end
  end
end


