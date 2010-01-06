require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
Configliere.use :encrypted

describe "Configliere::Encrypted" do
  before do
    @config = Configliere::Param.new :encrypted_param => 'foo_val'
    @config.define :encrypted_param, :encrypted => true
  end

  describe 'defining encrypted params' do
    it 'is encrypted if defined with :encrypted => true' do
      @config.encrypted_params.should include(:encrypted_param)
    end
    it 'is not encrypted if defined with :encrypted => false' do
      @config.define :another_param,   :encrypted => false
      @config.encrypted_params.should_not include(:another_param)
      @config.encrypted_params.should     include(:encrypted_param)
    end
    it 'is encrypted if not defined' do
      @config.encrypted_params.should_not include(:missing_param)
    end
  end

  describe 'encrypting encrypted params' do
    it 'successfully' do
      Configliere::Crypter.should_receive(:encrypt).with('foo_val', 'pass')
    end
    it 'fails if no pass is set' do
      @config.encrypted_get(:encrypted_param)
    end
  end
end

