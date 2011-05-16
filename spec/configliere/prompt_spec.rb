require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Configliere::Prompt" do
  before do
    @config = Configliere::Param.new
    @config.use :prompt
    @config.define :underpants, :description => 'boxers or briefs'
  end

  describe 'when the value is already set, #prompt_for' do
    it 'returns the value' do
      @config[:underpants] = :boxers
      @config.prompt_for(:underpants).should == :boxers
    end
    it 'returns the value even if nil' do
      @config[:underpants] = nil
      @config.prompt_for(:underpants).should == nil
    end
    it 'returns the value even if nil' do
      @config[:underpants] = false
      @config.prompt_for(:underpants).should == false
    end
  end

  describe 'when prompting, #prompt_for' do
    it 'prompts for a value if missing' do
      @config.should_receive(:ask).with("surprise_param? ")
      @config.prompt_for(:surprise_param)
    end
    it 'uses an explicit hint' do
      @config.should_receive(:ask).with("underpants (wearing any)? ")
      @config.prompt_for(:underpants, "wearing any")
    end
    it 'uses the description as hint if none given' do
      @config.should_receive(:ask).with("underpants (boxers or briefs)? ")
      @config.prompt_for(:underpants)
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

