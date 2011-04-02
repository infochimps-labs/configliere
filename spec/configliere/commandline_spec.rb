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

    it 'should not complain about bad single-letter flags by default' do
      ::ARGV.replace ['-pcz']
      @config.resolve!
      @config.rest.should == []
      @config.should == { :param_1 => true, :cat => true, :foo => nil}
    end

    it 'should raise an error about bad single-letter flags if asked' do
      ::ARGV.replace ['-pcz']
      @config.complain_about_bad_flags!
      lambda { @config.resolve! }.should raise_error(Configliere::Error)
    end
    
  end

  describe "constructing help messages" do
    it "should not display a help message about environment variables if no environment variables exist with documentation" do
      @config = Configliere::Param.new :param_1 => 'val 1', :cat => :hat
      @config.env_var_help.should be_nil
    end
  end
  
end

