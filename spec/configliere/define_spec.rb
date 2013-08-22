require 'spec_helper'

describe Configliere::Define do
  
  subject{ Configliere::Param.new :normal_param => 'normal' }

  describe 'defining any aspect of a param' do
    it 'adopts values' do
      subject.define :simple, :description => 'desc'
      subject.definition_of(:simple).should == { :description => 'desc'}
    end

    it 'returns self' do
      ret_val = subject.define :simple, :description => 'desc'
      ret_val.should equal(subject)
    end

    it 'merges new definitions' do
      subject.define :described_in_steps, :description => 'desc 1'
      subject.define :described_in_steps, :description => 'desc 2'
      subject.definition_of(:described_in_steps).should == { :description => 'desc 2'}
      subject.define :described_in_steps, :encrypted => true
      subject.definition_of(:described_in_steps).should == { :encrypted => true, :description => 'desc 2'}
    end

    it 'lists params defined as the given aspect' do
      subject.define :has_description,      :description => 'desc 1'
      subject.define :also_has_description, :description => 'desc 2'
      subject.define :no_description,       :something_else => 'foo'
      subject.params_with(:description).should include(:has_description)
      subject.params_with(:description).should include(:also_has_description)
      subject.params_with(:description).should_not include(:no_description)
    end
  end

  describe 'definition_of' do
    it 'with a param, gives me the description hash' do
      subject.define :has_description,      :description => 'desc 1'
      subject.definition_of(:has_description).should == { :description => 'desc 1' }
    end
    it 'with a param and attr, gives me the description hash' do
      subject.define :has_description,      :description => 'desc 1'
      subject.definition_of(:has_description, :description).should == 'desc 1'
    end
    it 'symbolizes the param' do
      subject.define :has_description,      :description => 'desc 1'
      subject.definition_of('has_description').should == { :description => 'desc 1' }
      subject.definition_of('has_description', 'description').should be_nil
    end
  end

  describe 'has_definition?' do
    before do
      subject.define :i_am_defined, :description => 'desc 1'
    end
    it 'is true if defined (one arg)' do
      subject.has_definition?(:i_am_defined).should == true
    end
    it 'is false if not defined (one arg)' do
      subject.has_definition?(:i_am_not_defined).should == false
    end
    it 'is true if defined and attribute is defined' do
      subject.has_definition?(:i_am_defined, :description).should == true
    end
    it 'is false if defined and attribute is defined' do
      subject.has_definition?(:i_am_defined, :zoink).should == false
    end
    it 'is false if not defined and attribute is given' do
      subject.has_definition?(:i_am_not_defined, :zoink).should == false
    end
  end

  it 'takes a description' do
    subject.define :has_description,      :description => 'desc 1'
    subject.define :also_has_description, :description => 'desc 2'
    subject.definition_of(:has_description, :description).should == 'desc 1'
  end

  describe 'type coercion' do
    [
      [:boolean, '0', false],  [:boolean, 0, false], [:boolean, '',  false], [:boolean, [],     true], [:boolean, nil, nil],
      [:boolean, '1', true],   [:boolean, 1, true],  [:boolean, '5', true],  [:boolean, 'true', true],
      [Integer, '5', 5],       [Integer, 5,   5],    [Integer, nil, nil],    [Integer, '', nil],
      [Integer, '5', 5],       [Integer, 5,   5],    [Integer, nil, nil],    [Integer, '', nil],
      [Float,   '5.2', 5.2],   [Float,   5.2, 5.2],  [Float, nil, nil],      [Float, '', nil],
      [Symbol,   'foo', :foo], [Symbol, :foo, :foo], [Symbol, nil, nil],     [Symbol, '', nil],
      [Date,     '1985-11-05',          Date.parse('1985-11-05')],               [Date, nil, nil],     [Date, '', nil],     [Date, 'blah', nil],
      [DateTime, '1985-11-05 11:00:00', DateTime.parse('1985-11-05 11:00:00')],  [DateTime, nil, nil], [DateTime, '', nil], [DateTime, 'blah', nil],
      [Array,  ['this', 'that', 'thother'], ['this', 'that', 'thother']],
      [Array,  'this,that,thother',         ['this', 'that', 'thother']],
      [Array,  'alone',                     ['alone'] ],
      [Array,  '',                          []        ],
      [Array,  nil,                         nil       ],
    ].each do |type, orig, desired|
      it "for #{type} converts #{orig.inspect} to #{desired.inspect}" do
        subject.define :has_type, :type => type
        subject[:has_type] = orig ; subject.resolve! ; subject[:has_type].should == desired
      end
    end

    it 'raises an error (FIXME: on resolve, which is not that great) if you define an unknown type' do
      subject.define :has_type, :type => 'bogus, man'
      subject[:has_type] = "WHOA" ;
      expect{ subject.resolve! }.to raise_error(ArgumentError, /Unknown type.*bogus, man/)
    end

    it 'converts :now to the current moment' do
      subject.define :has_type, :type => DateTime
      subject[:has_type] = 'now' ; subject.resolve! ; subject[:has_type].should be_within(4).of(DateTime.now)
      subject[:has_type] = :now  ; subject.resolve! ; subject[:has_type].should be_within(4).of(DateTime.now)
      subject.define :has_type, :type => Date
      subject[:has_type] = :now  ; subject.resolve! ; subject[:has_type].should be_within(4).of(Date.today)
      subject[:has_type] = 'now' ; subject.resolve! ; subject[:has_type].should be_within(4).of(Date.today)
    end
  end

  describe 'creates magical methods' do
    before do
      subject.define :has_magic_method, :default => 'val1'
      subject[:no_magic_method] = 'val2'
    end
    it 'answers to a getter if the param is defined' do
      subject.has_magic_method.should == 'val1'
    end
    it 'answers to a setter if the param is defined' do
      subject.has_magic_method = 'new_val1'
      subject.has_magic_method.should == 'new_val1'
      subject[:has_magic_method].should == 'new_val1'
    end
    it 'does not answer to a getter if the param is not defined' do
      lambda{ subject.no_magic_method }.should raise_error(NoMethodError)
    end
    it 'does not answer to a setter if the param is not defined' do
      lambda{ subject.no_magic_method = 3 }.should raise_error(NoMethodError)
    end
  end

  describe 'defining requireds' do
    before do
      subject.define :param_1, :required => true
      subject.define :param_2, :required => true
      subject.define :optional_1, :required => false
      subject.define :optional_2
    end
    it 'lists required params' do
      subject.params_with(:required).should include(:param_1)
      subject.params_with(:required).should include(:param_2)
    end
    it 'counts false values as present' do
      subject.defaults :param_1 => true, :param_2 => false
      subject.validate!.should equal(subject)
    end
    it 'counts nil-but-set values as missing' do
      subject.defaults :param_1 => true, :param_2 => nil
      lambda{ subject.validate! }.should raise_error(RuntimeError)
    end
    it 'counts never-set values as missing' do
      lambda{ subject.validate! }.should raise_error(RuntimeError)
    end
    it 'lists all missing values when it raises' do
      lambda{ subject.validate! }.should raise_error(RuntimeError, "Missing values for: param_1, param_2")
    end
  end

  describe 'defining deep keys' do
    it 'allows required params' do
      subject.define 'delorean.power_supply', :required => true
      subject[:'delorean.power_supply'] = 'household waste'
      subject.params_with(:required).should include(:'delorean.power_supply')
      subject.should == { :normal_param=>"normal", :delorean => { :power_supply => 'household waste' } }
      lambda{ subject.validate! }.should_not raise_error
    end

    it 'allows flags' do
      subject.define 'delorean.power_supply', :flag => 'p'
      subject.use :commandline
      ARGV.replace ['-p', 'household waste']
      subject.params_with(:flag).should include(:'delorean.power_supply')
      subject.resolve!
      subject.should == { :normal_param=>"normal", :delorean => { :power_supply => 'household waste' } }
      ARGV.replace []
    end

    it 'type converts' do
      subject.define 'delorean.power_supply', :type => Array
      subject.use :commandline
      ARGV.replace ['--delorean.power_supply=household waste,plutonium,lightning']
      subject.definition_of('delorean.power_supply', :type).should == Array
      subject.resolve!
      subject.should == { :normal_param=>"normal", :delorean => { :power_supply => ['household waste', 'plutonium', 'lightning'] } }
      ARGV.replace []
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
