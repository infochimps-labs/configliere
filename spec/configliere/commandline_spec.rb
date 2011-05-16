require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Configliere::Commandline" do
  before do
    @config = Configliere::Param.new :date => '11-05-1955', :cat => :hat
    @config.use :commandline
  end
  after do
    ::ARGV.replace []
  end

  describe "with long-format flags" do
    it 'accepts --param=val pairs' do
      ::ARGV.replace ['--enchantment=under_sea']
      @config.resolve!
      @config.should == { :enchantment => 'under_sea', :date => '11-05-1955', :cat => :hat}
    end
    it 'accepts --dotted.param.name=val pairs as deep keys' do
      ::ARGV.replace ['--dotted.param.name=my_val']
      @config.resolve!
      @config.rest.should be_empty
      @config.should == { :dotted => { :param => { :name => 'my_val' }}, :date => '11-05-1955', :cat => :hat }
    end
    it 'accepts --dashed-param-name=val pairs as deep keys' do
      ::ARGV.replace ['--dashed-param-name=my_val']
      @config.resolve!
      @config.rest.should be_empty
      @config.should == { :dashed => { :param => { :name => 'my_val' }}, :date => '11-05-1955', :cat => :hat }
    end
    it 'adopts only the last-seen of duplicate commandline flags' do
      ::ARGV.replace ['--date=A', '--date=B']
      @config.resolve!
      @config.rest.should be_empty
      @config.should == { :date => 'B', :cat => :hat}
    end
    it 'does NOT set a bare parameter (no "=") followed by a non-param to that value' do
      ::ARGV.replace ['--date', '11-05-1985', '--heavy', '--power.source', 'household waste', 'go']
      @config.resolve!
      @config.rest.should == ['11-05-1985', 'household waste', 'go']
      @config.should == { :date => true, :heavy => true, :power => { :source => true }, :cat => :hat }
    end
    it 'sets a bare parameter (no "=") to true' do
      ::ARGV.replace ['--date', '--deep.param']
      @config.resolve!
      @config.rest.should be_empty
      @config.should == { :date => true, :deep => { :param => true }, :cat => :hat}
    end
    it 'sets an explicit blank to nil' do
      ::ARGV.replace ['--date=', '--deep.param=']
      @config.resolve!
      @config.should == { :date => nil, :deep => { :param => nil }, :cat => :hat}
    end

    it 'captures non --param args into Settings.rest' do
      ::ARGV.replace ['--date', 'file1', 'file2']
      @config.resolve!
      @config.should == { :date => true, :cat => :hat}
      @config.rest.should == ['file1', 'file2']
    end

    it 'stops processing args on "--"' do
      ::ARGV.replace ['--date=A', '--', '--date=B']
      @config.resolve!
      @config.rest.should == ['--date=B']
      @config.should == { :date => 'A', :cat => :hat}
    end
  end

  describe "with single-letter flags" do
    before do
      @config.define :date,    :flag => :d
      @config.define :cat,     :flag => 'c'
      @config.define :process, :flag => :p
    end

    it 'accepts them separately' do
      ::ARGV.replace ['-p', '-c']
      @config.resolve!
      @config.rest.should == []
      @config.should == { :date => '11-05-1955', :cat => true, :process => true}
    end

    it 'accepts them as a group ("-abc")' do
      ::ARGV.replace ['-pc']
      @config.resolve!
      @config.rest.should == []
      @config.should == { :date => '11-05-1955', :cat => true, :process => true}
    end

    it 'accepts a value with -d=new_val' do
      ::ARGV.replace ['-d=new_val', '-c']
      @config.resolve!
      @config.rest.should == []
      @config.should == { :date => 'new_val', :cat => true }
    end

    it 'accepts a space-separated value (-d new_val)' do
      ::ARGV.replace ['-d', 'new_val', '-c', '-p']
      @config.resolve!
      @config.rest.should == []
      @config.should == { :date => 'new_val', :cat => true, :process => true }
    end

    it 'accepts a space-separated value only if the next arg is not a flag' do
      ::ARGV.replace ['-d', 'new_val', '-c', '-p', 'vigorously']
      @config.resolve!
      @config.rest.should == []
      @config.should == { :date => 'new_val', :cat => true, :process => 'vigorously' }
    end

    it 'stores unknown single-letter flags in unknown_params' do
      ::ARGV.replace ['-dcz']
      lambda{ @config.resolve! }.should_not raise_error(Configliere::Error)
      @config.should == { :date => true, :cat => true }
      @config.unknown_params.should == ['z']
    end
  end

  def capture_help_message
    stderr_output = ''
    @config.should_receive(:warn){|str| stderr_output << str }
    begin
      yield
      fail('should exit via system exit')
    rescue SystemExit
    end
    stderr_output
  end

  describe "the help message" do
    it 'displays help' do
      ::ARGV.replace ['--help']
      stderr_output = capture_help_message{ @config.resolve! }
      stderr_output.should_not be_nil
      stderr_output.should_not be_empty

      @config.help.should_not be_nil
      @config.help.should_not be_empty
    end

    it "displays the single-letter flags" do
      @config.define :cat, :flag => :c, :description => "I like single-letter commands."
      ::ARGV.replace ['--help']
      stderr_output = capture_help_message{ @config.resolve! }
      stderr_output.should match(/-c,/m)
    end

    it "displays command line options" do
      ::ARGV.replace ['--help']

      @config.define :logfile, :type => String,     :description => "Log file name", :default => 'myapp.log', :required => false
      @config.define :debug, :type => :boolean,     :description => "Log debug messages to console?", :required => false
      @config.define :dest_time, :type => DateTime, :description => "Arrival time", :required => true
      @config.define :takes_opt, :flag => 't',      :description => "Takes a single-letter flag '-t'"
      @config.define :foobaz, :internal => true,    :description => "You won't see me"
      @config.define 'delorean.power_source', :env_var => 'POWER_SOURCE', :description => 'Delorean subsytem supplying power to the Flux Capacitor.'
      @config.define :password, :required => true, :encrypted => true
      @config.description = 'This is a sample script to demonstrate the help message. Notice how pretty everything lines up YAY'

      stderr_output = capture_help_message{ @config.resolve! }
      stderr_output.should_not be_nil
      stderr_output.should_not be_empty

      stderr_output.should =~ %r{--debug\s}s                                 # type :boolean
      stderr_output.should =~ %r{--logfile=String\s}s                        # type String
      stderr_output.should =~ %r{--dest_time=DateTime[^\n]+\[Required\]}s    # shows required params
      stderr_output.should =~ %r{--password=String[^\n]+\[Encrypted\]}s      # shows encrypted params
      stderr_output.should =~ %r{--delorean.power_source=String\s}s          # undefined type
      stderr_output.should =~ %r{--password=String\s*password}s              # uses name as dummy description
      stderr_output.should =~ %r{-t, --takes_opt}s                           # single-letter flags

      stderr_output.should =~ %r{delorean\.power_source[^\n]+Env Var: POWER_SOURCE}s    # environment variable
      stderr_output.should =~ %r{This is a sample script}s                         # extra description
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

