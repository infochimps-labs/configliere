require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Configliere::Param" do
  before do
    @config = Configliere::Param.new
  end

  describe '#defaults' do
    it 'merges new params' do
      @config.defaults :hat => :cat, :basket => :lotion, :moon => { :man => :smiling }
      @config.defaults :basket => :tasket, :moon => { :cow => :jumping }
      @config.should == { :hat => :cat, :basket => :tasket, :moon => { :man => :smiling, :cow => :jumping } }
    end
  end

  describe 'setting vals' do
    it 'symbolizes keys' do
      @config.defaults :hat => :cat, :basket => :lotion
      @config['hat'] = :fedora
      @config['new'] = :unseen
      @config.should == { :hat => :fedora, :basket => :lotion, :new => :unseen }
    end
    it 'deep-sets dotted vals' do
      @config.defaults :hat => :cat, :basket => :lotion, :moon => { :man => :smiling }
      @config['moon.man'] = :cheesy
      @config[:moon][:man].should == :cheesy
      @config['moon.cheese.type'] = :tilsit
      @config[:moon][:cheese][:type].should == :tilsit
    end
    it 'deep-gets dotted vals' do
      hsh = { :hat => :cat, :basket => :lotion, :moon => { :man => :smiling, :cheese => {:type => :tilsit} } }
      @config.defaults hsh
      @config['moon.man'].should == :smiling
      @config['moon.cheese.type'].should == :tilsit
      @config['moon.cheese.smell'].should be_nil
      @config['moon.non.existent.interim.values'].should be_nil
      @config['moon.non'].should be_nil
      if (RUBY_VERSION >= '1.9') then lambda{ @config['hat.cat'] }.should raise_error(TypeError,     'TypeError: can\'t convert Symbol into Integer')
      else                            lambda{ @config['hat.cat'] }.should raise_error(NoMethodError, 'undefined method `[]\' for :cat:Symbol') end
      @config.should == hsh # shouldn't change from reading
    end
  end

end
