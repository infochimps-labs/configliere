require 'spec_helper'

# Highline does not work with JRuby 1.7.0+ as of Mid 2012. See https://github.com/JEG2/highline/issues/41.

describe "Configliere::Prompt", :if => load_sketchy_lib('highline/import') do
  
  subject{ Configliere::Param.new.use :prompt }

  before do    
    subject.define :underpants, :description => 'boxers or briefs'
  end

  context 'when the value is already set, #prompt_for' do
    it 'returns the value' do
      subject[:underpants] = :boxers
      subject.prompt_for(:underpants).should == :boxers
    end

    it 'returns the value even if nil' do
      subject[:underpants] = nil
      subject.prompt_for(:underpants).should == nil
    end

    it 'returns the value even if nil' do
      subject[:underpants] = false
      subject.prompt_for(:underpants).should == false
    end
  end

  context 'when prompting, #prompt_for' do
    it 'prompts for a value if missing' do
      subject.should_receive(:ask).with("surprise_param? ")
      subject.prompt_for(:surprise_param)
    end

    it 'uses an explicit hint' do
      subject.should_receive(:ask).with("underpants (wearing any)? ")
      subject.prompt_for(:underpants, "wearing any")
    end

    it 'uses the description as hint if none given' do
      subject.should_receive(:ask).with("underpants (boxers or briefs)? ")
      subject.prompt_for(:underpants)
    end
  end

  context '#resolve!' do
    it 'calls super and returns self' do
      Configliere::ParamParent.class_eval do def resolve!() dummy ; end ; end
      subject.should_receive(:dummy)
      subject.resolve!.should equal(subject)
      Configliere::ParamParent.class_eval do def resolve!() self ; end ; end
    end
  end
end
