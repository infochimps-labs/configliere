require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

# Highline does not work with JRuby 1.7.0+ as of Mid 2012. See https://github.com/JEG2/highline/issues/41.

describe "Configliere::Prompt", :if => load_sketchy_lib('highline/import') do
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
