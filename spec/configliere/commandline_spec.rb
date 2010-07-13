require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'configliere/commandline'

describe "Configliere::Commandline" do
  before do
    @config = Configliere::Param.new :param_1 => 'val 1', :cat => :hat
  end

  it 'handles --param=val pairs' do
    ::ARGV.replace ['--my_param=my_val']
    @config.resolve!
    @config.should == { :my_param => 'my_val', :param_1 => 'val 1', :cat => :hat}
  end
  it 'handles --dotted.param.name=val pairs' do
    ::ARGV.replace ['--dotted.param.name=my_val']
    @config.resolve!
    @config.rest.should be_empty
    @config.should == { :dotted => { :param => { :name => 'my_val' }}, :param_1 => 'val 1', :cat => :hat}
  end
  it 'handles --dashed-param-name=val pairs' do
    ::ARGV.replace ['--dashed-param-name=my_val']
    @config.resolve!
    @config.rest.should be_empty
    @config.should == { :dashed => { :param => { :name => 'my_val' }}, :param_1 => 'val 1', :cat => :hat}
  end
  it 'uses the last-seen of the commandline values' do
    ::ARGV.replace ['--param_1=A', '--param_1=B']
    @config.resolve!
    @config.rest.should be_empty
    @config.should == { :param_1 => 'B', :cat => :hat}
  end
  it 'sets a bare parameter (no "=") to true' do
    ::ARGV.replace ['--param_1', '--deep.param']
    @config.resolve!
    @config.rest.should be_empty
    @config.should == { :param_1 => true, :deep => { :param => true }, :cat => :hat}
  end
  it 'sets an explicit blank to nil' do
    ::ARGV.replace ['--param_1=', '--deep.param=']
    @config.resolve!
    @config.should == { :param_1 => nil, :deep => { :param => nil }, :cat => :hat}
  end

  it 'saves non --param args into rest' do
    ::ARGV.replace ['--param_1', 'file1', 'file2']
    @config.resolve!
    @config.should == { :param_1 => true, :cat => :hat}
    @config.rest.should == ['file1', 'file2']
  end

  it 'stops processing on "--"' do
    ::ARGV.replace ['--param_1=A', '--', '--param_1=B']
    @config.resolve!
    @config.rest.should == ['--param_1=B']
    @config.should == { :param_1 => 'A', :cat => :hat}
  end
  
  it 'should display help' do
    ::ARGV.replace ['--help']
    begin
      $stderr = StringIO.new
      begin
        @config.resolve!
        fail('should exit via system exit')
      rescue SystemExit
      end
      $stderr.string.should_not be_nil
      $stderr.string.should_not be_empty
    
      @config.help.should_not be_nil
      @config.help.should_not be_empty
    ensure
      $stderr = STDERR
    end
  end
  
  it "should display command line options" do
    ::ARGV.replace ['--help']
    @config.define :logfile, :type => String, :description => "Log filename, default is: myapp.log", :required => false
    @config.define :debug, :type => :boolean, :description => 'Log debug messages to console', :required => false
    @config.define :dest_time, :type => DateTime, :description => 'Arrival time', :required => true
    @config.define 'delorean.power_source', :env_var => 'POWER_SOURCE', :description => 'Delorean subsytem supplying power to the Flux Capacitor.'
    @config.define :password, :required => true, :encrypted => true
    @config.description = 'fee fie foe fum'
    
    begin
      $stderr = StringIO.new
      begin
        @config.resolve!
        fail('should exit via system exit')
      rescue SystemExit
      end
      str = $stderr.string
      should_not be_nil
      str.should_not be_empty
      puts str
      
      str.match(%r(--debug\s)).should_not be_nil                                  # type :boolean
      str.match(%r(--logfile=String\s)).should_not be_nil                         # type String
      str.match(%r(--dest_time=DateTime\s[^\n]+\[Required\])).should_not be_nil   # type DateTime, required
      str.match(%r(--delorean.power_source=String\s)).should_not be_nil           # undefined type
      str.match(%r(--password\s)).should be_nil                                   # undefined description

      str.match(%r(\sPOWER_SOURCE\s+delorean\.power_source)).should_not be_nil    # environment variable
      str.match(%r(fee\sfie\sfoe\sfum)).should_not be_nil                         # extra description
    ensure
      $stderr = STDERR
    end
  end

  after do
    ::ARGV.replace []
  end
end

