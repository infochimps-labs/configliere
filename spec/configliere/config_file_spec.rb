require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Configliere::ConfigFile do
  before do
    @config = Configliere::Param.new :my_param => 'default_val', :also_a_param => true
    FileUtils.stub! :mkdir_p
  end

  it 'is used by default' do
    @config.should respond_to(:read)
  end

  describe 'loading a config file' do
    before do
      @fake_file = '{ :my_param: val_from_file }'
    end

    describe 'successfully' do
      it 'with an absolute pathname uses it directly' do
        File.should_receive(:open).with(%r{/fake/path.yaml}).and_return(@fake_file)
        @config.read '/fake/path.yaml'
      end
      it 'with a simple filename, references it to the default config dir' do
        File.should_receive(:open).with(File.join(Configliere::DEFAULT_CONFIG_DIR, 'file.yaml')).and_return(@fake_file)
        @config.read 'file.yaml'
      end
      it 'returns the config object for chaining' do
        File.should_receive(:open).with(File.join(Configliere::DEFAULT_CONFIG_DIR, 'file.yaml')).and_return(@fake_file)
        @config.defaults :also_a_param => true
        @config.read('file.yaml').should == { :my_param => 'val_from_file', :also_a_param => true }
      end
      after do
        @config[:my_param].should == 'val_from_file'
      end
    end

    it 'no longer provides a default config file' do
      lambda{ @config.read(:my_settings) }.should raise_error(Configliere::DeprecatedError)
      defined?(Configliere::DEFAULT_CONFIG_FILE).should_not be_true
    end

    it 'warns but does not fail if the file is missing' do
      @config = Configliere::Param.new
      File.stub(:open).and_raise(Errno::ENOENT)
      @config.should_receive(:warn).with("Loading empty configliere settings file #{Configliere::DEFAULT_CONFIG_DIR}/nonexistent_file.yaml")
      @config.read('nonexistent_file.yaml').should == {}
    end


    describe 'with an environment scope' do
      before do
        @config.defaults :reload => :unset
        @hash_with_subenvs = { :development => { :reload => true }, :production => { :reload => false }}
        File.stub :open
        YAML.should_receive(:load).and_return(@hash_with_subenvs)
      end

      it 'slices out a subhash given by :env' do
        @config.read('f', :env => :development)
        @config.should == { :reload => true, :my_param => 'default_val', :also_a_param => true }
      end

      it 'slices out a different subhash with a different :env' do
        @config.read('f', :env => :production)
        @config.should == { :reload => false, :my_param => 'default_val', :also_a_param => true }
      end

      it 'does no slicing without the :env option' do
        @config.read('f')
        @config.should == { :development => { :reload => true }, :production => { :reload => false }, :reload => :unset, :my_param => 'default_val', :also_a_param => true }
      end

      it 'has no effect if the key given by :env option is absent' do
        @config.read('f', :env => :foobar)
        @config.should == { :reload => :unset, :my_param => 'default_val', :also_a_param => true }
      end

      it 'does not type convert the :env option' do
        @hash_with_subenvs['john_woo'] = { :reload => :sideways }
        @config.read('f', :env => 'john_woo')
        @config.should == { :reload => :sideways, :my_param => 'default_val', :also_a_param => true }
      end
    end
  end


  describe 'saves to a config file' do
    it 'with an absolute pathname, as given' do
      fake_file = StringIO.new('', 'w')
      File.should_receive(:open).with(%r{/fake/path.yaml}, 'w').and_yield(fake_file)
      fake_file.should_receive(:<<).with("--- \n:my_param: default_val\n:also_a_param: true\n")
      @config.save! '/fake/path.yaml'
    end

    it 'with a simple pathname, in the default config dir' do
      fake_file = StringIO.new('', 'w')
      File.should_receive(:open).with(Configliere::DEFAULT_CONFIG_DIR + '/file.yaml', 'w').and_yield(fake_file)
      fake_file.should_receive(:<<).with("--- \n:my_param: default_val\n:also_a_param: true\n")
      @config.save! 'file.yaml'
    end

    it 'and ensures the directory exists' do
      fake_file = StringIO.new('', 'w')
      File.stub!(:open).with(%r{/fake/path.yaml}, 'w').and_yield(fake_file)
      FileUtils.should_receive(:mkdir_p).with('/fake')
      @config.save! '/fake/path.yaml'
    end
  end

  describe '#resolve!' do
    it 'calls super and returns self' do
      Configliere::ParamParent.class_eval do def resolve!() dummy ; end ; end
      @config.should_receive(:dummy)
      @config.resolve!.should equal(@config)
      Configliere::ParamParent.class_eval do def resolve!() self ; end ; end
    end
  end

end

