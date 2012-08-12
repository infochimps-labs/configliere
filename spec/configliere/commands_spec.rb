require 'spec_helper'
require 'configliere/commands'

describe Configliere::Commands do
  
  subject{ Configliere::Param.new.use(:commands) }

  after{ ::ARGV.replace [] }

  context 'when no commands are defined' do
    
    its(:commands){ should be_empty }

    let(:args) { %w[ not_command_but_arg another_arg ] }

    it 'does not shift the ARGV when resolving' do
      ::ARGV.replace args
      subject.resolve!
      subject.rest.should == args
      subject.command_name.should be_nil
      subject.command_info.should be_nil
    end

    it 'still recognize a git-style-binary command' do
      ::ARGV.replace args
      File.should_receive(:basename).and_return('prog-subcommand')
      subject.resolve!
      subject.rest.should == args
      subject.command_name.should == :subcommand
      subject.command_info.should be_nil
    end
  end

  context 'a simple command' do
    let(:args) { %w[ the_command  --fuzziness=wuzzy extra_arg ] }

    before do
      subject.defaults(fuzziness: 'smooth')
      subject.define_command(:the_command, description: 'foobar')
    end

    it "should continue to parse flags when the command is given" do
      ::ARGV.replace args
      subject.resolve!
      subject.should == { fuzziness: 'wuzzy' }
    end

    it "should continue to set args when the command is given" do
      ::ARGV.replace args
      subject.resolve!
      subject.rest.should == ['extra_arg']
    end

    it "should recognize the command when given" do
      ::ARGV.replace args
      subject.resolve!
      subject.command_name.should == :the_command
      subject.command_info.should == { :description => "foobar", :config => { :fuzziness => 'wuzzy' } }
    end

    it "should recognize when the command is not given" do
      ::ARGV.replace ['bogus_command', '--fuzziness=wuzzy', 'an_arg']
      subject.resolve!
      subject.rest.should == ['bogus_command', 'an_arg']
      subject.command_name.should be_nil
    end
  end

  describe "a complex command" do
    before do
      subject.defaults :outer => 'val 1'
      subject.define_command "the_command", :description => "the command" do |cmd|
        cmd.define :inner, :description => "inside"
      end
    end

    it "should still recognize the outer param and the args" do
      ::ARGV.replace ['the_command', '--outer=wuzzy', 'an_arg', '--inner=buzz']
      subject.resolve!
      subject.rest.should == ['an_arg']
      subject.command_name.should == :the_command
      subject[:outer].should == 'wuzzy'
    end

    it "should recognize the inner param" do
      ::ARGV.replace ['the_command', '--outer=wuzzy', 'an_arg', '--inner=buzz']
      subject.resolve!
      subject[:inner].should == 'buzz'
      subject.command_info[:config][:inner].should == 'buzz'
    end
  end

  def capture_help_message
    stderr_output = ''
    subject.should_receive(:warn){|str| stderr_output << str }
    begin
      yield
      fail('should exit via system exit')
    rescue SystemExit
      true # pass
    end
    stderr_output
  end

  describe "the help message" do
    before do
      subject.define_command :run, :description => "forrest"
      subject.define_command :stop, :description => "hammertime"
      subject.define :reel, :type => Integer
    end

    it "displays a modified usage" do
      ::ARGV.replace ['--help']
      stderr_output = capture_help_message{ subject.resolve! }
      stderr_output.should =~ %r{usage:.*\[command\]}m
    end

    it "displays the commands and their descriptions" do
      ::ARGV.replace ['--help']
      stderr_output = capture_help_message{ subject.resolve! }
      stderr_output.should =~ %r{Available commands:\s+run\s*forrest\s+stop\s+hammertime}m
      stderr_output.should =~ %r{Params:.*--reel=Integer\s+reel}m
    end
  end

  describe '#resolve!' do
    it 'calls super and returns self' do
      Configliere::ParamParent.class_eval do def resolve!() dummy ; end ; end
      subject.should_receive(:dummy)
      subject.resolve!.should equal(subject)
      Configliere::ParamParent.class_eval do def resolve!() self ; end ; end
    end
  end

  describe '#validate!' do
    it 'calls super and returns self' do
      Configliere::ParamParent.class_eval do def validate!() dummy ; end ; end
      subject.should_receive(:dummy)
      subject.validate!.should equal(subject)
      Configliere::ParamParent.class_eval do def validate!() self ; end ; end
    end
  end

end
