require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DeepHash do
  before(:each) do
    @hash = DeepHash.new.merge!({ :hsh1a => { :hsh2 => { :key3 => "val3" }, :key2 => "val2" }, :key1b => 'val1b' })
  end

  describe "#deep_merge!" do
    it "merges two subhashes when they share a key" do
      @hash.deep_merge!(:hsh1a => { :hsh2 => { :key3a => "val3a" } })
      @hash.should == { :hsh1a => { :hsh2 => { :key3a => "val3a", :key3 => "val3" }, :key2 => "val2" }, :key1b => 'val1b' }
    end
    it "preserves values in the original" do
      @hash.deep_merge! :other_key => "other_val"
      @hash[:hsh1a][:key2].should == "val2"
      @hash[:other_key].should == "other_val"
    end
    it "replaces values from the given DeepHash" do
      @hash.deep_merge!(:hsh1a => { :hsh2 => { :key3 => "new_val3" }, :key2 => { "other2" => "other_val2" }})
      @hash[:hsh1a][:hsh2][:key3].should == 'new_val3'
      @hash[:hsh1a][:key2].should == { "other2" => "other_val2" }
    end
  end


  describe "#deep_set" do
    it 'should set a new value (single arg)' do
      @hash.deep_set :new_key, 'new_val'
      @hash[:new_key].should == 'new_val'
    end
    it 'should set a new value (multiple args)' do
      @hash.deep_set :hsh1a, :hsh2, :new_key, 'new_val'
      @hash[:hsh1a][:hsh2][:new_key].should == 'new_val'
    end
    it 'should replace an existing value (single arg)' do
      @hash.deep_set :key1b, 'new_val'
      @hash[:key1b].should == 'new_val'
    end
    it 'should replace an existing value (multiple args)' do
      @hash.deep_set :hsh1a, :hsh2, 'new_val'
      @hash[:hsh1a][:hsh2].should == 'new_val'
    end
    it 'should auto-vivify intermediate hashes' do
      @hash.deep_set :one, :two, :three, :four, 'new_val'
      @hash[:one][:two][:three][:four].should == 'new_val'
    end
  end

  describe "#deep_delete" do
    it 'should remove the key from the array (multiple args)' do
      @hash.deep_delete(:hsh1a)
      @hash[:hsh1a].should be_nil
      @hash.should == { :key1b => 'val1b'}
    end
    it 'should remove the key from the array (multiple args)' do
      @hash.deep_delete(:hsh1a, :hsh2, :key3)
      @hash[:hsh1a][:hsh2][:key3].should be_nil
      @hash.should == {:key1b=>"val1b", :hsh1a=>{:key2=>"val2", :hsh2=>{}}}
    end
    it 'should return the value if present (single args)' do
      returned_val = @hash.deep_delete(:key1b)
      returned_val.should == 'val1b'
    end
    it 'should return the value if present (multiple args)' do
      returned_val = @hash.deep_delete(:hsh1a, :hsh2, :key3)
      returned_val.should == 'val3'
    end
    it 'should return nil if the key is absent (single arg)' do
      returned_val = @hash.deep_delete(:hsh1a, :hsh2, :missing_key)
      returned_val.should be_nil
    end
    it 'should return nil if the key is absent (multiple args)' do
      returned_val = @hash.deep_delete(:missing_key)
      returned_val.should be_nil
    end
  end

end
