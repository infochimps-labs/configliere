require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
Configliere.use :define

describe "Configliere::Define" do
  before do
    @config = Configliere::Param.new :normal_param => 'normal'
  end
  describe 'defining any aspect of a param' do
    it 'adopts values' do
      @config.define :param, :description => 'desc'
      @config.param_definitions[:param].should == { :description => 'desc'}
    end
    it 'merges new definitions' do
      @config.define :param, :description => 'desc 1'
      @config.define :param, :description => 'desc 2'
      @config.param_definitions[:param].should == { :description => 'desc 2'}
      @config.define :param, :encrypted => true
      @config.param_definitions[:param].should == { :encrypted => true, :description => 'desc 2'}
    end
    it 'lists params defined as the given aspect' do
      @config.define :param_1, :description => 'desc 1'
      @config.define :param_2, :description => 'desc 2'
      @config.define :param_3, :something_else => 'foo'
      @config.send(:params_with, :description).should include(:param_1)
      @config.send(:params_with, :description).should include(:param_2)
    end
  end

  describe 'defining descriptions' do
    before do
      @config.define :param_1, :description => 'desc 1'
      @config.define :param_2, :description => 'desc 2'
    end
    it 'shows description for a param' do
      @config.description_for(:param_1).should == 'desc 1'
    end
    it 'lists descriptions' do
      @config.descriptions.should == { :param_1 => 'desc 1', :param_2 => 'desc 2'}
    end
    it 'lists descriptions' do
      @config.described_params.should include(:param_1)
      @config.described_params.should include(:param_2)
    end
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
        @config.define :param, :type => type
        @config[:param] = orig ; @config.resolve! ; @config[:param].should == desired
      end
    end
    it 'converts :now to the current moment' do
      @config.define :param, :type => DateTime
      @config[:param] = 'now' ; @config.resolve! ; @config[:param].should be_close(DateTime.now, 4)
      @config[:param] = :now  ; @config.resolve! ; @config[:param].should be_close(DateTime.now, 4)
      @config.define :param, :type => Date
      @config[:param] = :now  ; @config.resolve! ; @config[:param].should be_close(Date.today, 4)
      @config[:param] = 'now' ; @config.resolve! ; @config[:param].should be_close(Date.today, 4)
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
      @config.required_params.should include(:param_1)
      @config.required_params.should include(:param_2)
    end
    it 'counts false values as required' do
      @config.defaults :param_1 => true, :param_2 => false
      @config.validate!.should == true
    end
    it 'counts nil-but-set values as missing' do
      @config.defaults :param_1 => true, :param_2 => nil
      lambda{ @config.validate! }.should raise_error("Missing values for param_2")
    end
    it 'counts never-set values as missing' do
      lambda{ @config.validate! }.should raise_error("Missing values for param_1, param_2")
    end
    it 'lists all missing values when it raises' do
      Configliere.use :define
      lambda{ @config.validate! }.should raise_error("Missing values for param_1, param_2")
    end
  end
end


