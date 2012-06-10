require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Configliere::ConfigFile do
  before do
    @config = Configliere::Param.new :my_param => 'default_val', :also_a_param => true
    FileUtils.stub! :mkdir_p
  end

  it 'is used by default' do
    @config.should respond_to(:read)
  end

  describe 'loading a yaml config file' do
    before do
      @fake_file = ':my_param: val_from_file'
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
  end

  describe 'loading a json config file' do
    before do
      require 'json'
      @fake_file = '{"my_param":"val_from_file"}'
    end

    describe 'successfully' do
      it 'with an absolute pathname uses it directly' do
        File.should_receive(:open).with(%r{/fake/path.json}).and_return(@fake_file)
        @config.read '/fake/path.json'
      end
      it 'with a simple filename, references it to the default config dir' do
        File.should_receive(:open).with(File.join(Configliere::DEFAULT_CONFIG_DIR, 'file.json')).and_return(@fake_file)
        @config.read 'file.json'
      end
      it 'returns the config object for chaining' do
        File.should_receive(:open).with(File.join(Configliere::DEFAULT_CONFIG_DIR, 'file.json')).and_return(@fake_file)
        @config.defaults :also_a_param => true
        @config.read('file.json').should == { :my_param => 'val_from_file', :also_a_param => true }
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
      @config.should_receive(:warn).with("Loading empty configliere settings file #{Configliere::DEFAULT_CONFIG_DIR}/nonexistent_file.json")
      @config.read('nonexistent_file.json').should == {}
    end
  end

  describe '#read_yaml' do
    before do
      @config.merge! :reload => :whatever
      @simple_yaml       = { :my_param => 'override_val', 'also_a_param' => true, 'strkey' => 'val', :falsekey => false, :nilkey => nil }.to_yaml
      @yaml_with_subenvs = { :development => { :reload => true }, :production => { :reload => false }}.to_yaml
    end

    it 'loads yaml' do
      @config.read_yaml(@simple_yaml)
      @config.should     == { :reload => :whatever, :my_param => 'override_val', :also_a_param  => true, :strkey  => 'val', :falsekey => false, :nilkey => nil }
      @config.should_not == { :reload => :whatever, :my_param => 'override_val', 'also_a_param' => true, 'strkey' => 'val', :falsekey => false, :nilkey => nil }
    end

    describe 'with an environment scope' do
      it 'slices out a subhash given by :env' do
        @config.read_yaml(@yaml_with_subenvs, :env => :development)
        @config.should == { :reload => true, :my_param => 'default_val', :also_a_param => true }
      end

      it 'slices out a different subhash with a different :env' do
        @config.read_yaml(@yaml_with_subenvs, :env => :production)
        @config.should == { :reload => false, :my_param => 'default_val', :also_a_param => true }
      end

      it 'does no slicing without the :env option' do
        @config.read_yaml(@yaml_with_subenvs)
        @config.should == { :development => { :reload => true }, :production => { :reload => false }, :reload => :whatever, :my_param => 'default_val', :also_a_param => true }
      end

      it 'has no effect if the key given by :env option is absent' do
        @config.read_yaml(@yaml_with_subenvs, :env => :foobar)
        @config.should == { :reload => :whatever, :my_param => 'default_val', :also_a_param => true }
      end

      it 'lets you use a string if the loading hash has a string' do
        yaml_with_string_subenv = { 'john_woo' => { :reload => :sideways }}.to_yaml
        @config.read_yaml(yaml_with_string_subenv, :env => 'john_woo')
        @config.should == { :reload => :sideways, :my_param => 'default_val', :also_a_param => true }
      end
    end
  end

  describe 'saves to a config file' do
    it 'with an absolute pathname, as given' do
      fake_file = StringIO.new('', 'w')
      File.should_receive(:open).with(%r{/fake/path.yaml}, 'w').and_yield(fake_file)
      fake_file.should_receive(:<<).with({ :my_param => 'default_val', :also_a_param => true }.to_yaml)
      @config.save! '/fake/path.yaml'
    end

    it 'with a simple pathname, in the default config dir' do
      fake_file = StringIO.new('', 'w')
      File.should_receive(:open).with(Configliere::DEFAULT_CONFIG_DIR + '/file.yaml', 'w').and_yield(fake_file)
      fake_file.should_receive(:<<).with({ :my_param => 'default_val', :also_a_param => true }.to_yaml)
      @config.save! 'file.yaml'
    end

    it 'and ensures the directory exists' do
      fake_file = StringIO.new('', 'w')
      File.stub!(:open).with(%r{/fake/path.yaml}, 'w').and_yield(fake_file)
      FileUtils.should_receive(:mkdir_p).with(%r{/fake})
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

  describe '#validate!' do
    it 'calls super and returns self' do
      Configliere::ParamParent.class_eval do def validate!() dummy ; end ; end
      @config.should_receive(:dummy)
      @config.validate!.should equal(@config)
      Configliere::ParamParent.class_eval do def validate!() self ; end ; end
    end
  end

end
