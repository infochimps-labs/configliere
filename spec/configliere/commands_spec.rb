require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Configliere::Commands" do
  before do
    @config = Configliere::Param.new
    @config.use :commands
  end

  after do
    ::ARGV.replace []
  end

  describe "when no commands are defined" do
    it "should know that no commands are defined" do
      @config.commands.should be_empty
    end

    it "should not shift the ARGV when resolving" do
      ::ARGV.replace ['not_command_but_arg', 'another_arg']
      @config.resolve!
      @config.rest.should == ['not_command_but_arg', 'another_arg']
      @config.command_name.should be_nil
      @config.command_info.should be_nil
    end

    it "should still recognize a git-style-binary command" do
      ::ARGV.replace ['not_command_but_arg', 'another_arg']
      File.should_receive(:basename).and_return('prog-subcommand')
      @config.resolve!
      @config.rest.should == ['not_command_but_arg', 'another_arg']
      @config.command_name.should == :subcommand
      @config.command_info.should be_nil
    end
  end

  describe "a simple command" do
    before do
      @config.defaults :fuzziness => 'smooth'
      @config.define_command :the_command, :description => "foobar"
    end

    it "should continue to parse flags when the command is given" do
      ::ARGV.replace ['the_command', '--fuzziness=wuzzy', 'an_arg']
      @config.resolve!
      @config.should == { :fuzziness => 'wuzzy' }
    end

    it "should continue to set args when the command is given" do
      ::ARGV.replace ['the_command', '--fuzziness=wuzzy', 'an_arg']
      @config.resolve!
      @config.rest.should == ['an_arg']
    end

    it "should recognize the command when given" do
      ::ARGV.replace ['the_command', '--fuzziness=wuzzy', 'an_arg']
      @config.resolve!
      @config.command_name.should == :the_command
      @config.command_info.should == { :description => "foobar", :config => { :fuzziness => 'wuzzy' } }
    end

    it "should recognize when the command is not given" do
      ::ARGV.replace ['bogus_command', '--fuzziness=wuzzy', 'an_arg']
      @config.resolve!
      @config.rest.should == ['bogus_command', 'an_arg']
      @config.command_name.should be_nil
    end
  end

  describe "a complex command" do
    before do
      @config.defaults :outer => 'val 1'
      @config.define_command "the_command", :description => "the command" do |cmd|
        cmd.define :inner, :description => "inside"
      end
    end

    it "should still recognize the outer param and the args" do
      ::ARGV.replace ['the_command', '--outer=wuzzy', 'an_arg', '--inner=buzz']
      @config.resolve!
      @config.rest.should == ['an_arg']
      @config.command_name.should == :the_command
      @config[:outer].should == 'wuzzy'
    end

    it "should recognize the inner param" do
      ::ARGV.replace ['the_command', '--outer=wuzzy', 'an_arg', '--inner=buzz']
      @config.resolve!
      @config[:inner].should == 'buzz'
      @config.command_info[:config][:inner].should == 'buzz'
    end
  end


  def capture_help_message
    stderr_output = ''
    @config.should_receive(:warn){|str| stderr_output << str }
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
      @config.define_command :run, :description => "forrest"
      @config.define_command :stop, :description => "hammertime"
      @config.define :reel, :type => Integer
    end

    it "displays a modified usage" do
      ::ARGV.replace ['--help']
      stderr_output = capture_help_message{ @config.resolve! }
      stderr_output.should =~ %r{usage:.*\[command\]}m
    end

    it "displays the commands and their descriptions" do
      ::ARGV.replace ['--help']
      stderr_output = capture_help_message{ @config.resolve! }
      stderr_output.should =~ %r{Available commands:\s+run\s*forrest\s+stop\s+hammertime}m
      stderr_output.should =~ %r{Params:.*--reel=Integer\s+reel}m
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
