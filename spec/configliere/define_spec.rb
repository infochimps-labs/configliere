require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Configliere::Define" do
  before do
    @config = Configliere::Param.new :normal_param => 'normal'
  end

  describe 'defining any aspect of a param' do
    it 'adopts values' do
      @config.define :simple, :description => 'desc'
      @config.definition_of(:simple).should == { :description => 'desc'}
    end

    it 'merges new definitions' do
      @config.define :described_in_steps, :description => 'desc 1'
      @config.define :described_in_steps, :description => 'desc 2'
      @config.definition_of(:described_in_steps).should == { :description => 'desc 2'}
      @config.define :described_in_steps, :encrypted => true
      @config.definition_of(:described_in_steps).should == { :encrypted => true, :description => 'desc 2'}
    end

    it 'lists params defined as the given aspect' do
      @config.define :has_description,      :description => 'desc 1'
      @config.define :also_has_description, :description => 'desc 2'
      @config.define :no_description,       :something_else => 'foo'
      @config.params_with(:description).should include(:has_description)
      @config.params_with(:description).should include(:also_has_description)
      @config.params_with(:description).should_not include(:no_description)
    end
  end

  describe 'definition_of' do
    it 'with a param, gives me the description hash' do
      @config.define :has_description,      :description => 'desc 1'
      @config.definition_of(:has_description).should == { :description => 'desc 1' }
    end
    it 'with a param and attr, gives me the description hash' do
      @config.define :has_description,      :description => 'desc 1'
      @config.definition_of(:has_description, :description).should == 'desc 1'
    end
    it 'symbolizes the param' do
      @config.define :has_description,      :description => 'desc 1'
      @config.definition_of('has_description').should == { :description => 'desc 1' }
      @config.definition_of('has_description', 'description').should be_nil
    end
  end

  describe 'has_definition?' do
    before do
      @config.define :i_am_defined, :description => 'desc 1'
    end
    it 'is true if defined' do
      @config.has_definition?(:i_am_defined).should == true
    end
    it 'is false if not defined' do
      @config.has_definition?(:i_am_not_defined).should == false
    end
  end

  it 'takes a description' do
    @config.define :has_description,      :description => 'desc 1'
    @config.define :also_has_description, :description => 'desc 2'
    @config.definition_of(:has_description, :description).should == 'desc 1'
  end

  require 'date'; require 'time'
  describe 'type coercion' do
    [
      [:boolean, '0', false],  [:boolean, 0, false], [:boolean, '',  false], [:boolean, [],     true], [:boolean, nil, nil],
      [:boolean, '1', true],   [:boolean, 1, true],  [:boolean, '5', true],  [:boolean, 'true', true],
      [Integer, '5', 5],       [Integer, 5,   5],    [Integer, nil, nil],    [Integer, '', nil],
      [Integer, '5', 5],       [Integer, 5,   5],    [Integer, nil, nil],    [Integer, '', nil],
      [Float,   '5.2', 5.2],   [Float,   5.2, 5.2],  [Float, nil, nil],      [Float, '', nil],
      [Symbol,   'foo', :foo], [Symbol, :foo, :foo], [Symbol, nil, nil],     [Symbol, '', nil],
      [Date,     '1985-11-05',           Date.parse('1985-11-05')],               [Date, nil, nil],     [Date, '', nil],     [Date, 'blah', nil],
      [DateTime, '1985-11-05 11:00:00', DateTime.parse('1985-11-05 11:00:00')],  [DateTime, nil, nil], [DateTime, '', nil], [DateTime, 'blah', nil],
      [Array,  ['this', 'that', 'thother'], ['this', 'that', 'thother']],
      [Array,  'this,that,thother',         ['this', 'that', 'thother']],
      [Array,  'alone',                     ['alone'] ],
      [Array,  '',                          []        ],
      [Array,  nil,                         nil       ],
    ].each do |type, orig, desired|
      it "for #{type} converts #{orig.inspect} to #{desired.inspect}" do
        @config.define :has_type, :type => type
        @config[:has_type] = orig ; @config.resolve! ; @config[:has_type].should == desired
      end
    end
    it 'converts :now to the current moment' do
      @config.define :has_type, :type => DateTime
      @config[:has_type] = 'now' ; @config.resolve! ; @config[:has_type].should be_within(4).of(DateTime.now, 4)
      @config[:has_type] = :now  ; @config.resolve! ; @config[:has_type].should be_within(4).of(DateTime.now, 4)
      @config.define :has_type, :type => Date
      @config[:has_type] = :now  ; @config.resolve! ; @config[:has_type].should be_within(4).of(Date.today, 4)
      @config[:has_type] = 'now' ; @config.resolve! ; @config[:has_type].should be_within(4).of(Date.today, 4)
    end
  end

  describe 'creates magical methods' do
    before do
      @config.define :has_magic_method, :default => 'val1'
      @config[:no_magic_method] = 'val2'
    end
    it 'answers to a getter if the param is defined' do
      @config.has_magic_method.should == 'val1'
    end
    it 'answers to a setter if the param is defined' do
      @config.has_magic_method = 'new_val1'
      @config.has_magic_method.should == 'new_val1'
      @config[:has_magic_method].should == 'new_val1'
    end
    it 'does not answer to a getter if the param is not defined' do
      lambda{ @config.no_magic_method }.should raise_error(NoMethodError)
    end
    it 'does not answer to a setter if the param is not defined' do
      lambda{ @config.no_magic_method = 3 }.should raise_error(NoMethodError)
    end
  end

  describe 'defining requireds' do
    before do
      @config.define :param_1, :required => true
      @config.define :param_2, :required => true
      @config.define :optional_1, :required => false
      @config.define :optional_2
    end
    it 'lists required params' do
      @config.params_with(:required).should include(:param_1)
      @config.params_with(:required).should include(:param_2)
    end
    it 'counts false values as present' do
      @config.defaults :param_1 => true, :param_2 => false
      @config.validate!.should equal(@config)
    end
    it 'counts nil-but-set values as missing' do
      @config.defaults :param_1 => true, :param_2 => nil
      lambda{ @config.validate! }.should raise_error(RuntimeError)
    end
    it 'counts never-set values as missing' do
      lambda{ @config.validate! }.should raise_error(RuntimeError)
    end
    it 'lists all missing values when it raises' do
      lambda{ @config.validate! }.should raise_error(RuntimeError, "Missing values for: param_1, param_2")
    end
  end

  describe 'defining deep keys' do
    it 'allows required params' do
      @config.define 'delorean.power_supply', :required => true
      @config[:'delorean.power_supply'] = 'household waste'
      @config.params_with(:required).should include(:'delorean.power_supply')
      @config.should == { :normal_param=>"normal", :delorean => { :power_supply => 'household waste' } }
      lambda{ @config.validate! }.should_not raise_error
    end

    it 'allows flags' do
      @config.define 'delorean.power_supply', :flag => 'p'
      @config.use :commandline
      ARGV.replace ['-p', 'household waste']
      @config.params_with(:flag).should include(:'delorean.power_supply')
      @config.resolve!
      @config.should == { :normal_param=>"normal", :delorean => { :power_supply => 'household waste' } }
      ARGV.replace []
    end

    it 'type converts' do
      @config.define 'delorean.power_supply', :type => Array
      @config.use :commandline
      ARGV.replace ['--delorean.power_supply=household waste,plutonium,lightning']
      @config.definition_of('delorean.power_supply', :type).should == Array
      @config.resolve!
      @config.should == { :normal_param=>"normal", :delorean => { :power_supply => ['household waste', 'plutonium', 'lightning'] } }
      ARGV.replace []
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

