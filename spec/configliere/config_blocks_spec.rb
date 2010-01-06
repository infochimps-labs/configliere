require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
Configliere.use :config_blocks

describe "Configliere::ConfigBlocks" do
  before do
    @config = Configliere::Param.new :normal_param => 'normal'
  end

  describe 'resolving' do
    it 'runs blocks' do
      @block_watcher = 'watcher'
      @block_watcher.should_receive(:fnord).with(@config)
      @config.finally{|arg| @block_watcher.fnord(arg) }
      @config.resolve!
    end
    it 'resolves blocks last' do
      Configliere.use :config_blocks, :define, :encrypted
      @config.should_receive(:resolve_types!).ordered
      @config.should_receive(:resolve_finally_blocks!).ordered
      @config.resolve!
    end
  end

end


