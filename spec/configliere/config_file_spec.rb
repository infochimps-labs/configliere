require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
Configliere.use :config_file

describe "Configliere::ConfigFile" do
  before do
    @config = Configliere.new :my_param => 'val'
  end

  describe 'loads a config file' do
    before do
      @config = Configliere::Param.new :my_param => 'val'
      @fake_file = '{ :my_param: val }'
    end
    describe 'successfully' do
      it 'loads a symbol name from the default config file' do
        File.should_receive(:open).with(Configliere::DEFAULT_CONFIG_FILE).and_return(':my_settings: ' + @fake_file)
        @config.read :my_settings
      end
      it 'loads an absolute pathname from the given file' do
        File.should_receive(:open).with('/fake/path.yaml').and_return(@fake_file)
        @config.read '/fake/path.yaml'
      end
      it 'loads a simple filename from the default config dir' do
        File.should_receive(:open).with(Configliere::DEFAULT_CONFIG_DIR + '/file.yaml').and_return(@fake_file)
        @config.read 'file.yaml'
      end
      after do
        @config[:my_param].should == 'val'
      end
    end
    describe 'in edge cases' do
      it 'handles a file not found' do
        @config = Configliere::Param.new
        File.stub(:open).and_raise(Errno::ENOENT)
        @config.read('nonexistent_file.yaml').should == {}
      end
    end
  end

  describe 'saves to a config file' do
    describe 'successfully' do
      it 'saves a symbol name to the default config file' do
        Configliere::ConfigFile.should_receive(:merge_into_yaml_file).
          with(Configliere::DEFAULT_CONFIG_FILE, :my_settings, { :my_param => 'val'})
        @config.save! :my_settings
      end
      it 'saves a pathname to the given file' do
        fake_file = StringIO.new('', 'w')
        File.should_receive(:open).with('/fake/path.yaml', 'w').and_yield(fake_file)
        fake_file.should_receive(:<<).with("--- \n:my_param: val\n")
        @config.save! '/fake/path.yaml'
      end
    end
  end

  describe 'merge_into_yaml_file' do
    it 'merges, leaving existing values put' do
      fake_file = StringIO.new(":my_settings: { :my_param: orig_val }\n:other_settings: { :that_param: other_val }", 'r+')
      File.should_receive(:open).with('/fake/path.yaml').and_return(fake_file)
      File.should_receive(:open).with('/fake/path.yaml', 'w').and_yield(fake_file)
      mock_dump = 'mock_dump'
      YAML.should_receive(:dump).with({ :my_settings => { :my_param => 'new_val'}, :other_settings => { :that_param => 'other_val'}}).and_return(mock_dump)
      fake_file.should_receive(:<<).with(mock_dump)
      Configliere::ConfigFile.merge_into_yaml_file '/fake/path.yaml', :my_settings, :my_param => 'new_val'
    end
  end

  describe 'maps handles to filenames' do
    it 'loads a symbol name from the default config file' do
      @config.send(:filename_for_handle, :my_settings).should == Configliere::DEFAULT_CONFIG_FILE
    end
    it 'loads an absolute pathname from the given file' do
      @config.send(:filename_for_handle, '/fake/path.yaml').should == '/fake/path.yaml'
    end
    it 'loads a simple filename from the default config dir' do
      @config.send(:filename_for_handle, 'file.yaml').should == Configliere::DEFAULT_CONFIG_DIR + '/file.yaml'
    end
  end

end

