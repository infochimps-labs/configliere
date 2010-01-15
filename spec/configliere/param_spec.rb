require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Configliere::Param" do
  before do
    @config = Configliere::Param.new :hat => :cat, :basket => :lotion, :moon => { :man => :smiling }
  end

  describe '#defaults' do
    it 'merges new params' do
      @config.defaults :basket => :tasket, :moon => { :cow => :jumping }
      @config.should == { :hat => :cat, :basket => :tasket, :moon => { :man => :smiling, :cow => :jumping } }
    end
  end

  describe '#[]=' do
    it 'symbolizes keys' do
      @config['hat'] = :fedora
      @config['new'] = :unseen
      @config.should == { :hat => :fedora, :basket => :lotion, :new => :unseen, :moon => { :man => :smiling } }
    end
    it 'deep-sets dotted vals, replacing values' do
      @config['moon.man'] = :cheesy
      @config[:moon][:man].should == :cheesy
    end
    it 'deep-sets dotted vals, creating new values' do
      @config['moon.cheese.type'] = :tilsit
      @config[:moon][:cheese][:type].should == :tilsit
    end
    it 'deep-sets dotted vals, auto-vivifying intermediate hashes' do
      @config['this.that.the_other'] = :fuhgeddaboudit
      @config[:this][:that][:the_other].should == :fuhgeddaboudit
    end
  end

  describe '#[]' do
    it 'deep-gets dotted vals' do
      hsh = { :hat => :cat, :basket => :lotion, :moon => { :man => :smiling, :cheese => {:type => :tilsit} } }
      @config.defaults hsh
      @config['moon.man'].should == :smiling
      @config['moon.cheese.type'].should == :tilsit
      @config['moon.cheese.smell'].should be_nil
      @config['moon.non.existent.interim.values'].should be_nil
      @config['moon.non'].should be_nil
      if (RUBY_VERSION >= '1.9') then lambda{ @config['hat.cat'] }.should raise_error(TypeError)
      else                            lambda{ @config['hat.cat'] }.should raise_error(NoMethodError, 'undefined method `[]\' for :cat:Symbol') end
      @config.should == hsh # shouldn't change from reading (specifically, shouldn't autovivify)
    end
  end

end
