require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
Configliere.use :commands

describe "Configliere::Commands" do

  after do
    ::ARGV.replace []
  end

  describe "when no commands are defined" do
    before do
      @config = Configliere::Param.new
    end

    it "should know that no commands are defined" do
      @config.commands.should be_empty
    end

    it "should not shift the ARGV when resolving" do
      ::ARGV.replace ['not_command_but_arg', 'another_arg']
      @config.resolve!
      @config.rest.should == ['not_command_but_arg', 'another_arg']
      @config.command.should be_nil
    end

    it "should still recognize a git-style binary command" do
      ::ARGV.replace ['not_command_but_arg', 'another_arg']
      File.should_receive(:basename).and_return('prog-subcommand')
      @config.resolve!
      @config.rest.should == ['not_command_but_arg', 'another_arg']
      @config.command_name.should == 'subcommand'
      @config.command.should be_nil
    end
  end

  describe "a simple command" do
    before do
      @config = Configliere::Param.new :param => 'val 1'
      @config.define_command "the_command", :description => "foobar"
    end

    it "should continue to parse flags when the command is given" do
      ::ARGV.replace ['the_command', '--param=wuzz', 'an_arg']
      @config.resolve!
      @config.should == { :param => 'wuzz' }
    end

    it "should continue to set args when the command is given" do
      ::ARGV.replace ['the_command', '--param=wuzz', 'an_arg']
      @config.resolve!
      @config.rest.should == ['an_arg']
    end

    it "should recognize the command when given" do
      ::ARGV.replace ['the_command', '--param=wuzz', 'an_arg']
      @config.resolve!
      @config.command_name.should == 'the_command'
    end

    it "should recognize when the command is not given" do
      ::ARGV.replace ['bogus_command', '--param=wuzz', 'an_arg']
      @config.resolve!
      @config.rest.should == ['bogus_command', 'an_arg']
      @config.command_name.should be_nil
    end
  end

  describe "a complex command" do
    before do
      @config = Configliere::Param.new :outer_param => 'val 1'
      @config.define_command "the_command", :description => "the command" do |command|
        command.define :inner_param, :description => "inside"
      end
    end

    it "should still recognize the outer param and the args" do
      ::ARGV.replace ['the_command', '--outer_param=wuzz', 'an_arg', '--inner_param=buzz']
      @config.resolve!
      @config.rest.should == ['an_arg']
      @config.command_name.should == 'the_command'
      @config[:outer_param].should == 'wuzz'
    end

    it "should recognize the inner param" do
      ::ARGV.replace ['the_command', '--outer_param=wuzz', 'an_arg', '--inner_param=buzz']
      @config.resolve!
      @config[:inner_param].should == 'buzz'
      @config.command[:config][:inner_param].should == 'buzz'
    end

  end
end

