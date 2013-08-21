require 'spec_helper'
require 'configliere/commandline'

describe Configliere::Commandline do
  
  subject{ Configliere::Param.new(:date => '11-05-1955', :cat => :hat).use :commandline }
  
  after{ ::ARGV.replace [] }

  describe "with long-format argvs" do
    it 'accepts --param=val pairs' do
      ::ARGV.replace ['--enchantment=under_sea']
      subject.resolve!
      subject.should == { :enchantment => 'under_sea', :date => '11-05-1955', :cat => :hat}
    end

    it 'accepts --dotted.param.name=val pairs as deep keys' do
      ::ARGV.replace ['--dotted.param.name=my_val']
      subject.resolve!
      subject.rest.should be_empty
      subject.should == { :dotted => { :param => { :name => 'my_val' }}, :date => '11-05-1955', :cat => :hat }
    end

    it 'NO LONGER accepts --dashed-param-name=val pairs as deep keys' do
      ::ARGV.replace ['--dashed-param-name=my_val']
      subject.should_receive(:warn).with("Configliere uses _underscores not dashes for params")
      subject.resolve!
      subject.rest.should be_empty
      subject.should == { :'dashed-param-name' => 'my_val', :date => '11-05-1955', :cat => :hat }
    end

    it 'adopts only the last-seen of duplicate commandline flags' do
      ::ARGV.replace ['--date=A', '--date=B']
      subject.resolve!
      subject.rest.should be_empty
      subject.should == { :date => 'B', :cat => :hat}
    end

    it 'does NOT set a bare parameter (no "=") followed by a non-param to that value' do
      ::ARGV.replace ['--date', '11-05-1985', '--heavy', '--power.source', 'household waste', 'go']
      subject.resolve!
      subject.rest.should == ['11-05-1985', 'household waste', 'go']
      subject.should == { :date => true, :heavy => true, :power => { :source => true }, :cat => :hat }
    end

    it 'sets a bare parameter (no "=") to true' do
      ::ARGV.replace ['--date', '--deep.param']
      subject.resolve!
      subject.rest.should be_empty
      subject.should == { :date => true, :deep => { :param => true }, :cat => :hat}
    end

    it 'sets an explicit blank to nil' do
      ::ARGV.replace ['--date=', '--deep.param=']
      subject.resolve!
      subject.should == { :date => nil, :deep => { :param => nil }, :cat => :hat}
    end

    it 'captures non --param args into Settings.rest' do
      ::ARGV.replace ['--date', 'file1', 'file2']
      subject.resolve!
      subject.should == { :date => true, :cat => :hat}
      subject.rest.should == ['file1', 'file2']
    end

    it 'stops processing args on "--"' do
      ::ARGV.replace ['--date=A', '--', '--date=B']
      subject.resolve!
      subject.rest.should == ['--date=B']
      subject.should == { :date => 'A', :cat => :hat}
    end

    it 'places undefined argvs into #unknown_argvs' do
      subject.define :raven, :description => 'squawk'
      ::ARGV.replace ['--never=more', '--lenore', '--raven=ray_lewis']
      subject.resolve!
      subject.unknown_argvs.should == [:never, :lenore]
      subject.should == { :date => '11-05-1955', :cat => :hat, :never => 'more', :lenore => true, :raven => 'ray_lewis' }
    end
  end

  describe "with single-letter flags" do
    before do
      subject.define :date,    :flag => :d
      subject.define :cat,     :flag => 'c'
      subject.define :process, :flag => :p
    end

    it 'accepts them separately' do
      ::ARGV.replace ['-p', '-c']
      subject.resolve!
      subject.rest.should == []
      subject.should == { :date => '11-05-1955', :cat => true, :process => true}
    end

    it 'accepts them as a group ("-abc")' do
      ::ARGV.replace ['-pc']
      subject.resolve!
      subject.rest.should == []
      subject.should == { :date => '11-05-1955', :cat => true, :process => true}
    end

    it 'accepts a value with -d=new_val' do
      ::ARGV.replace ['-d=new_val', '-c']
      subject.resolve!
      subject.rest.should == []
      subject.should == { :date => 'new_val', :cat => true }
    end

    it 'stores unknown flags with values in unknown_argvs' do
      ::ARGV.replace ['-f=path/to/file']
      subject.resolve!
      subject.unknown_argvs.should == ['f']
    end

    it 'accepts a space-separated value (-d new_val)' do
      ::ARGV.replace ['-d', 'new_val', '-c', '-p']
      subject.resolve!
      subject.rest.should == []
      subject.should == { :date => 'new_val', :cat => true, :process => true }
    end

    it 'accepts a space-separated value only if the next arg is not a flag' do
      ::ARGV.replace ['-d', 'new_val', '-c', '-p', 'vigorously']
      subject.resolve!
      subject.rest.should == []
      subject.should == { :date => 'new_val', :cat => true, :process => 'vigorously' }
    end

    it 'stores unknown single-letter flags in unknown_argvs' do
      ::ARGV.replace ['-dcz']
      lambda{ subject.resolve! }.should_not raise_error(Configliere::Error)
      subject.should == { :date => true, :cat => true }
      subject.unknown_argvs.should == ['z']
    end

    it 'stores unknown single-letter flags in unknown_argvs, even when singular' do
      ::ARGV.replace ['-T']
      lambda{ subject.resolve! }.should_not raise_error(Configliere::Error)
      subject.unknown_argvs.should == ['T']
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
    it 'displays help' do
      ::ARGV.replace ['--help']
      stderr_output = capture_help_message{ subject.resolve! }
      stderr_output.should_not be_nil
      stderr_output.should_not be_empty

      subject.help.should_not be_nil
      subject.help.should_not be_empty
    end

    it "displays the single-letter flags" do
      subject.define :cat, :flag => :c, :description => "I like single-letter commands."
      ::ARGV.replace ['--help']
      stderr_output = capture_help_message{ subject.resolve! }
      stderr_output.should match(/-c,/m)
    end

    it "displays command line options" do
      ::ARGV.replace ['--help']

      subject.define :logfile, :type => String,     :description => "Log file name", :default => 'myapp.log', :required => false
      subject.define :debug, :type => :boolean,     :description => "Log debug messages to console?", :required => false
      subject.define :dest_time, :type => DateTime, :description => "Arrival time", :required => true
      subject.define :takes_opt, :flag => 't',      :description => "Takes a single-letter flag '-t'"
      subject.define :foobaz, :internal => true,    :description => "You won't see me"
      subject.define :password, :required => true, :encrypted => true
      subject.define 'delorean.power_source', :env_var => 'POWER_SOURCE', :description => 'Delorean subsytem supplying power to the Flux Capacitor.'
      subject.description = 'This is a sample script to demonstrate the help message. Notice how pretty everything lines up YAY'

      stderr_output = capture_help_message{ subject.resolve! }
      stderr_output.should_not be_nil
      stderr_output.should_not be_empty

      stderr_output.should =~ %r{--debug\s}s                                         # type :boolean
      stderr_output.should =~ %r{--logfile=String\s}s                                # type String
      stderr_output.should =~ %r{--dest_time=DateTime[^\n]+\[Required\]}s            # shows required params
      stderr_output.should =~ %r{--password=String[^\n]+\[Encrypted\]}s              # shows encrypted params
      stderr_output.should =~ %r{--delorean.power_source=String\s}s                  # undefined type
      stderr_output.should =~ %r{--password=String\s*password}s                      # uses name as dummy description
      stderr_output.should =~ %r{-t, --takes_opt}s                                   # single-letter flags

      stderr_output.should =~ %r{delorean\.power_source[^\n]+Env Var: POWER_SOURCE}s # environment variable
      stderr_output.should =~ %r{This is a sample script}s                           # extra description
    end

    it 'lets me die' do
      stderr_output = ''
      subject.should_receive(:dump_help).with("****\nhi mom\n****")
      subject.should_receive(:exit).with(3)
      subject.die("hi mom", 3)
    end
  end

  describe 'recycling a commandline' do
    it 'exports dashed flags' do
      subject.define :has_underbar, :type => Integer,  :default => 1
      subject.define :missing,      :type => Integer
      subject.define :truthy,       :type => :boolean, :default => true
      subject.define :falsehood,    :type => :boolean, :default => false      
      subject.dashed_flags(:has_underbar, :missing, :truthy).should == %w[ --has-underbar=1 --truthy   ]
      subject.dashed_flags(:falsehood, :date, :cat).should          == %w[ --date=11-05-1955 --cat=hat ]
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
