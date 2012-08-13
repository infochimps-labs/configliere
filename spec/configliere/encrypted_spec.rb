require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Configliere::Encrypted", :if => check_openssl do
  before do
    @config = Configliere::Param.new :secret => 'encrypt_me', :normal_param => 'normal'
    @config.use :encrypted
    @config.define :secret, :encrypted => true
    @config[:encrypt_pass] = 'pass'
  end

  describe 'defines encrypted params' do
    it 'with :encrypted => true' do
      @config.send(:encrypted_params).should include(:secret)
    end
    it 'but not if :encrypted => false' do
      @config.define :another_param,   :encrypted => false
      @config.send(:encrypted_params).should_not include(:another_param)
      @config.send(:encrypted_params).should     include(:secret)
    end
    it 'only if :encrypted is given' do
      @config.send(:encrypted_params).should_not include(:missing_param)
    end
  end

  describe 'the encrypt_pass' do
    it 'will take an environment variable if any exists' do
      @config[:encrypt_pass] = nil
      ENV.should_receive(:[]).with('ENCRYPT_PASS').at_least(:once).and_return('monkey')
      @config.send(:export)
      @config.send(:instance_variable_get, "@encrypt_pass").should == 'monkey'
    end
    it 'will take an internal value if given, and remove it' do
      @config[:encrypt_pass] = 'hello'
      @config.send(:export)
      @config.send(:instance_variable_get, "@encrypt_pass").should == 'hello'
      @config[:encrypt_pass].should be_nil
      @config.has_key?(:encrypt_pass).should_not be_true
    end
  end

  describe 'encrypts' do
    it 'all params with :encrypted' do
      Configliere::Crypter.should_receive(:encrypt).with('encrypt_me', 'pass').and_return('ok_encrypted')
      @config.send(:export).should == { :normal_param => 'normal', :encrypted_secret => 'ok_encrypted'}
    end

    it 'fails unless encrypt_pass is set' do
      # create the config but don't set an encrypt_pass
      @config = Configliere::Param.new :secret => 'encrypt_me', :normal_param => 'normal'
      @config.use :encrypted
      lambda{ @config.send(:encrypted, @config[:secret]) }.should raise_error('Missing encryption password!')
    end
  end

  describe 'decrypts' do
    it 'all params marked encrypted' do
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
      FileUtils.stub(:mkdir_p)
      File.should_receive(:open).and_yield([])
      YAML.should_receive(:dump).with({ :normal_param => "normal", :encrypted_secret => @encrypted_str })
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

  describe '#resolve!' do
    it 'calls super and returns self' do
      Configliere::ParamParent.class_eval do def resolve!() dummy ; end ; end
      @config.should_receive(:dummy)
      @config.resolve!.should equal(@config)
      Configliere::ParamParent.class_eval do def resolve!() self ; end ; end
    end

    it 'removes the encrypt_pass from sight' do
      @config[:encrypt_pass] = 'hello'
      @config.resolve!
      @config.send(:instance_variable_get, "@encrypt_pass").should == 'hello'
      @config[:encrypt_pass].should be_nil
      @config.has_key?(:encrypt_pass).should_not be_true
    end
  end

  describe '#validate!' do
    it 'calls super and returns self' do
      Configliere::ParamParent.class_eval do def validate!() dummy ; end ; end
      @config.should_receive(:dummy)
      @config.validate!.should equal(@config)
      Configliere::ParamParent.class_eval do def validate!() self ; end ; end
    end
  end

end
