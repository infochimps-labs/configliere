require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
Configliere.use :commandline

describe "Configliere::Commandline" do

  after do
    ::ARGV.replace []
  end

  describe "processing long-format flags" do
    before do
      @config = Configliere::Param.new :param_1 => 'val 1', :cat => :hat
    end

    it 'should handle --param=val pairs' do
      ::ARGV.replace ['--my_param=my_val']
      @config.resolve!
      @config.should == { :my_param => 'my_val', :param_1 => 'val 1', :cat => :hat}
    end
    it 'should handle --dotted.param.name=val pairs' do
      ::ARGV.replace ['--dotted.param.name=my_val']
      @config.resolve!
      @config.rest.should be_empty
      @config.should == { :dotted => { :param => { :name => 'my_val' }}, :param_1 => 'val 1', :cat => :hat}
    end
    it 'should handle --dashed-param-name=val pairs' do
      ::ARGV.replace ['--dashed-param-name=my_val']
      @config.resolve!
      @config.rest.should be_empty
      @config.should == { :dashed => { :param => { :name => 'my_val' }}, :param_1 => 'val 1', :cat => :hat}
    end
    it 'should handle the last-seen of the commandline values' do
      ::ARGV.replace ['--param_1=A', '--param_1=B']
      @config.resolve!
      @config.rest.should be_empty
      @config.should == { :param_1 => 'B', :cat => :hat}
    end
    it 'should set a bare parameter (no "=") to true' do
      ::ARGV.replace ['--param_1', '--deep.param']
      @config.resolve!
      @config.rest.should be_empty
      @config.should == { :param_1 => true, :deep => { :param => true }, :cat => :hat}
    end
    it 'should set an explicit blank to nil' do
      ::ARGV.replace ['--param_1=', '--deep.param=']
      @config.resolve!
      @config.should == { :param_1 => nil, :deep => { :param => nil }, :cat => :hat}
    end

    it 'should save non --param args into rest' do
      ::ARGV.replace ['--param_1', 'file1', 'file2']
      @config.resolve!
      @config.should == { :param_1 => true, :cat => :hat}
      @config.rest.should == ['file1', 'file2']
    end

    it 'should stop processing on "--"' do
      ::ARGV.replace ['--param_1=A', '--', '--param_1=B']
      @config.resolve!
      @config.rest.should == ['--param_1=B']
      @config.should == { :param_1 => 'A', :cat => :hat}
    end
  end

  describe "processing single-letter flags" do

    before do
      @config = Configliere::Param.new :param_1 => 'val 1', :cat => nil, :foo => nil
      @config.param_definitions = { :param_1 => { :flag => :p }, :cat =>  { :flag => 'c' } }
    end

    it 'should parse flags given separately' do
      ::ARGV.replace ['-p', '-c']
      @config.resolve!
      @config.rest.should == []
      @config.should == { :param_1 => true, :cat => true, :foo => nil}
    end

    it 'should parse flags given together' do
      ::ARGV.replace ['-pc']
      @config.resolve!
      @config.rest.should == []
      @config.should == { :param_1 => true, :cat => true, :foo => nil}
    end

    # it 'should parse a single-letter flag with a value' do
    #   ::ARGV.replace ['-p=new_val', '-c']
    #   @config.resolve!
    #   @config.rest.should == []
    #   @config.should == { :param_1 => 'new_val', :cat => true, :foo => nil }
    # end

    it 'should complain about bad single-letter flags by default' do
      ::ARGV.replace ['-pcz']
      lambda { @config.resolve! }.should raise_error(Configliere::Error)
    end
  end

  describe "help messages with single-letter flags" do

    before do
      @config = Configliere::Param.new
      @config.use :commandline, :define
      @config.define :cat, :flag => :c, :description => "I like single-letter commands."
    end

    it "display the single-letter flags" do
      ::ARGV.replace ['--help']
      actual = ""
      $stderr.stub(:puts) do |line|
        actual += line
      end
      @config.stub(:exit)
      @config.resolve!
      actual.should match(/-c,/m)
    end
  end

  describe "constructing help messages" do

    before do
      @config = Configliere::Param.new :param_1 => 'val 1', :cat => :hat
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

      @config.define :logfile, :type => String,     :description => "Log file name", :default => 'myapp.log', :required => false
      @config.define :debug, :type => :boolean,     :description => "Log debug messages to console?", :required => false
      @config.define :dest_time, :type => DateTime, :description => "Arrival time", :required => true
      @config.define :takes_opt, :flag => 't',      :description => "Takes a single-letter flag '-t'"
      @config.define :foobaz, :internal => true,    :description => "You won't see me"
      @config.define 'delorean.power_source', :env_var => 'POWER_SOURCE', :description => 'Delorean subsytem supplying power to the Flux Capacitor.'
      @config.define :password, :required => true, :encrypted => true
      @config.description = 'This is a sample script to demonstrate the help message. Notice how pretty everything lines up YAY'

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

        str.should =~ %r{--debug\s}s                                 # type :boolean
        str.should =~ %r{--logfile=String\s}s                        # type String
        str.should =~ %r{--dest_time=DateTime[^\n]+\[Required\]}s    # shows required params
        str.should =~ %r{--password=String[^\n]+\[Encrypted\]}s      # shows encrypted params
        str.should =~ %r{--delorean.power_source=String\s}s          # undefined type
        str.should =~ %r{--password=String\s*password}s              # uses name as dummy description
        str.should =~ %r{-t, --takes_opt}s                           # single-letter flags

        str.should =~ %r{delorean\.power_source[^\n]+Env Var: POWER_SOURCE}s    # environment variable
        str.should =~ %r{This is a sample script}s                         # extra description
      ensure
        $stderr = STDERR
      end
    end
  end

end

