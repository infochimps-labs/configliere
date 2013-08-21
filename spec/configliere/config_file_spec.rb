require 'spec_helper'

describe Configliere::ConfigFile do
  let(:default_params) { { :my_param => 'default_val', :also_a_param => true } }

  subject{ Configliere::Param.new default_params }

  it 'is included by default' do
    subject.class.included_modules.should include(described_class)
  end

  context '#read' do
    let(:file_params) { { :my_param => 'val_from_file' } }
    let(:file_string) { file_params.to_yaml           }
    let(:file_path)   { '/absolute/path.yaml'         }

    before{ File.stub(:open).and_return(file_string) }

    it 'returns the config object for chaining' do
      subject.read(file_path).should == subject
    end

    context 'a yaml file' do
      let(:file_path) { '/absolute/path.yaml' }

      it 'reads successfully' do
        subject.should_receive(:read_yaml).with(file_string, {})
        subject.read file_path
      end

      it 'merges the data' do
        subject.read(file_path).should == default_params.merge(file_params)
      end
    end

    context 'a json file' do
      let(:file_path)   { '/absolute/path.json' }
      let(:file_string) { '{"my_param":"val_from_file"}'   }

      it 'reads successfully' do
        subject.should_receive(:read_json).with(file_string, {})
        subject.read file_path
      end

      it 'merges the data' do
        subject.read(file_path).should == default_params.merge(file_params)
      end
    end

    context 'given a symbol' do
      let(:file_path) { :my_settings }

      it 'no longer provides a default config file' do
        expect{ subject.read(file_path) }.to raise_error(Configliere::DeprecatedError)
        defined?(Configliere::DEFAULT_CONFIG_FILE).should_not be_true
      end
    end

    context 'given a nonexistent file' do
      let(:file_path) { 'nonexistent.conf' }

      it 'warns but does not fail if the file is missing' do
        File.stub(:open).and_raise(Errno::ENOENT)
        subject.should_receive(:warn).with("Loading empty configliere settings file #{subject.default_conf_dir}/#{file_path}")
        subject.read(file_path).should == subject
      end
    end

    context 'given an absolute path' do
      let(:file_path) { '/absolute/path.yaml' }

      it 'uses it directly' do
        File.should_receive(:open).with(file_path).and_return(file_string)
        subject.read file_path
      end
    end

    context 'given a simple filename' do
      let(:file_path) { 'simple_path.yaml' }

      it 'references it to the default config dir' do
        File.should_receive(:open).with(File.join(subject.default_conf_dir, file_path)).and_return(file_string)
        subject.read file_path
      end
    end

    context 'with options' do
      let(:file_params) { { :development => { :reload => true }, :production => { :reload => false } } }

      before{ subject.merge!(:reload => 'whatever') }

      context ':env key' do
        context 'valid :env' do
          let(:opts) { { :env => :development } }

          it 'slices out a subhash given by :env' do
            subject.read(file_path, opts)
            subject.should == default_params.merge(:reload => true)
          end
        end

        context 'invalid :env' do
          let(:opts) { { :env => :not_there } }

          it 'has no effect if the key given by :env option is absent' do
            subject.read(file_path, opts)
            subject.should == default_params.merge(:reload => 'whatever')
          end
        end
      end

      context 'no :env key' do
        let(:opts) { Hash.new }

        it 'does no slicing without the :env option' do
          subject.read(file_path, opts)
          subject.should == default_params.merge(:reload => 'whatever').merge(file_params)
        end
      end
    end
  end

  context '#save!' do
    let(:fake_file) { StringIO.new('', 'w') }

    context 'given an absolute pathname' do
      let(:file_path) { '/absolute/path.yaml' }

      it 'saves the filename as given' do
        File.should_receive(:open).with(file_path, 'w').and_yield(fake_file)
        FileUtils.stub(:mkdir_p)
        fake_file.should_receive(:<<).with(default_params.to_yaml)
        subject.save! file_path
      end
    end

    context 'given a simple pathname' do
      let(:file_path) { 'simple_path.yaml' }

      it 'saves the filename in the default config dir' do
        File.should_receive(:open).with(File.join(subject.default_conf_dir, file_path), 'w').and_yield(fake_file)
        fake_file.should_receive(:<<).with(default_params.to_yaml)
        subject.save! file_path
      end

      it 'ensures the directory exists' do
        File.should_receive(:open).with(File.join(subject.default_conf_dir, file_path), 'w').and_yield(fake_file)
        FileUtils.should_receive(:mkdir_p).with(subject.default_conf_dir.to_s)
        subject.save! file_path
      end
    end
  end

  context '#resolve!' do
    around do |example|
      Configliere::ParamParent.class_eval{ def resolve!() parent_method ; end }
      example.run
      Configliere::ParamParent.class_eval{ def resolve!() self ; end }
    end

    it 'calls super and returns self' do
      subject.should_receive(:parent_method)
      subject.resolve!.should equal(subject)
    end
  end

  describe '#validate!' do
    around do |example|
      Configliere::ParamParent.class_eval{ def validate!() parent_method ; end }
      example.run
      Configliere::ParamParent.class_eval{ def validate!() self ; end }
    end

    it 'calls super and returns self' do
      subject.should_receive(:parent_method)
      subject.validate!.should equal(subject)
    end
  end

  context '#load_configuration_in_order!' do
    let(:scope) { 'test' }

    before{ subject.stub(:determine_conf_location).and_return('conf_dir') }

    it 'resolves configuration in order' do
      subject.should_receive(:determine_conf_location).with(:machine, scope).ordered
      subject.should_receive(:determine_conf_location).with(:user, scope).ordered
      subject.should_receive(:determine_conf_location).with(:app, scope).ordered
      subject.should_receive(:resolve!).ordered
      subject.load_configuration_in_order!(scope)
    end
  end
end
