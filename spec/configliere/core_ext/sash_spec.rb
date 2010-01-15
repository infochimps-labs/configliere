require File.expand_path(File.join(File.dirname(__FILE__), '../../spec_helper'))

class AwesomeHash < Hash
end

describe Sash do
  before(:each) do
    @hash = { "str_key" => "strk_val", :sym_key => "symk_val" }
    @sub  = AwesomeHash.new("str_key" => "strk_val", :sym_key => "symk_val")
  end


  describe "#deep_merge!" do
    before do
      @sash = Sash.new :hsh1 => { :hsh2 => { :key3 => "val3" }, :key2 => "val2" }
    end
    it "merges two subhashes when they share a key" do
      @sash.deep_merge!(:hsh1 => { :hsh2 => { :key3a => "val3a" } })
      @sash.should == { :hsh1 => { :hsh2 => { :key3a => "val3a", :key3 => "val3" }, :key2 => "val2" } }
    end
    it "merges two subhashes when they share a symbolized key" do
      @sash.deep_merge!(:hsh1 => { "hsh2" => { "key3a" => "val3a" } })
      @sash.should == { :hsh1 => { :hsh2  => { :key3a  => "val3a", :key3 => "val3" }, :key2 => "val2" } }
    end
    it "preserves values in the original" do
      @sash.deep_merge! :other_key => "other_val"
      @sash[:other_key].should == "other_val"
      @sash[:hsh1][:key2].should == "val2"
    end

    it "converts all keys into symbols when param is a Hash"  do
      @sash.deep_merge!(:hsh1 => { "hsh2" => { "key3a" => "val3a" } })
      @sash.should == { :hsh1 => { :hsh2 => { :key3a => "val3a", :key3 => "val3" }, :key2 => "val2" } }
    end
    it "converts all Hash values into Sashes if param is a Hash"  do
      @sash.deep_merge!({:hsh1 => { :hsh2 => { :key3a => "val3a" } }, :other1 => { "other2" => "other_val2" }})
      @sash[:hsh1].should be_an_instance_of(Sash)
      @sash[:hsh1][:hsh2].should be_an_instance_of(Sash)
      @sash[:other1].should be_an_instance_of(Sash)
    end
    it "replaces values from the given Hash" do
      @sash.deep_merge!(:hsh1 => { :hsh2 => { :key3 => "new_val3" }, :key2 => { "other2" => "other_val2" }})
      @sash[:hsh1][:hsh2][:key3].should == 'new_val3'
      @sash[:hsh1][:key2].should == { :other2 => "other_val2" }
    end
  end

  describe "#initialize" do
    it 'converts all keys into symbols when param is a Hash' do
      sash = Sash.new(@hash)
      sash.keys.any? { |key| key.is_a?(String) }.should be_false
    end

    it 'converts all pure Hash values into Sashes if param is a Hash' do
      sash = Sash.new :sym_key => @hash

      sash[:sym_key].should be_an_instance_of(Sash)
      # sanity check
      sash[:sym_key][:sym_key].should == "symk_val"
    end

    it 'doesn not convert Hash subclass values into Sashes' do
      sash = Sash.new :sub => @sub
      sash[:sub].should be_an_instance_of(AwesomeHash)
    end

    it 'converts all value items if value is an Array' do
      sash = Sash.new :arry => { :sym_key => [@hash] }

      sash[:arry].should be_an_instance_of(Sash)
      # sanity check
      sash[:arry][:sym_key].first[:sym_key].should == "symk_val"

    end

    it 'delegates to superclass constructor if param is not a Hash' do
      sash = Sash.new("dash berlin")

      sash["unexisting key"].should == "dash berlin"
    end
  end # describe "#initialize"



  describe "#update" do
    it 'converts all keys into symbols when param is a Hash' do
      sash = Sash.new(@hash)
      sash.update("starry" => "night")

      sash.keys.any?{|key| key.is_a?(String) }.should be_false
    end

    it 'converts all Hash values into Sashes if param is a Hash' do
      sash = Sash.new :hash => @hash
      sash.update(:hash => { :sym_key => "is buggy in Ruby 1.8.6" })

      sash[:hash].should be_an_instance_of(Sash)
    end
  end # describe "#update"



  describe "#[]=" do
    it 'converts key into symbol' do
      sash = Sash.new(@hash)
      sash["str_key"] = { "starry" => "night" }

      sash.keys.any?{|key| key.is_a?(String) }.should be_false
    end

    it 'converts all Hash value into Sash' do
      sash = Sash.new :hash => @hash
      sash[:hash] = { :sym_key => "is buggy in Ruby 1.8.6" }

      sash[:hash].should be_an_instance_of(Sash)
    end
  end # describe "#[]="



  describe "#key?" do
    before(:each) do
      @sash = Sash.new(@hash)
    end

    it 'converts key before lookup' do
      @sash.key?("str_key").should be_true
      @sash.key?(:str_key).should be_true

      @sash.key?("sym_key").should be_true
      @sash.key?(:sym_key).should be_true

      @sash.key?(:rainclouds).should be_false
      @sash.key?("rainclouds").should be_false
    end

    it 'is aliased as include?' do
      @sash.include?("str_key").should be_true
      @sash.include?(:str_key).should be_true

      @sash.include?("sym_key").should be_true
      @sash.include?(:sym_key).should be_true

      @sash.include?(:rainclouds).should be_false
      @sash.include?("rainclouds").should be_false
    end

    it 'is aliased as member?' do
      @sash.member?("str_key").should be_true
      @sash.member?(:str_key).should be_true

      @sash.member?("sym_key").should be_true
      @sash.member?(:sym_key).should be_true

      @sash.member?(:rainclouds).should be_false
      @sash.member?("rainclouds").should be_false
    end
  end # describe "#key?"

  def arrays_should_be_equal arr1, arr2
    arr1.sort_by{|s| s.to_s }.should == arr2.sort_by{|s| s.to_s }
  end

  describe "#dup" do
    it 'returns instance of Sash' do
      Sash.new(@hash).dup.should be_an_instance_of(Sash)
    end

    it 'preserves keys' do
      sash = Sash.new(@hash)
      dup  = sash.dup

      arrays_should_be_equal sash.keys, dup.keys
    end

    it 'preserves value' do
      sash = Sash.new(@hash)
      dup  = sash.dup

      arrays_should_be_equal sash.values, dup.values
    end
  end



  describe "#to_hash" do
    it 'returns instance of Hash' do
      Sash.new(@hash).to_hash.should be_an_instance_of(Hash)
    end

    it 'preserves keys' do
      sash = Sash.new(@hash)
      converted  = sash.to_hash
      arrays_should_be_equal sash.keys, converted.keys
    end

    it 'preserves value' do
      sash = Sash.new(@hash)
      converted = sash.to_hash
      arrays_should_be_equal sash.values, converted.values
    end
  end



  describe "#stringify_keys" do
    it 'returns instance of Sash' do
      Sash.new(@hash).stringify_keys.should be_an_instance_of(Hash)
    end

    it 'converts keys to symbols' do
      sash = Sash.new(@hash)
      converted  = sash.stringify_keys

      converted_keys = converted.keys.sort{|k1, k2| k1.to_s <=> k2.to_s}
      orig_keys = sash.keys.map{|k| k.to_sym}.sort{|i1, i2| i1.to_s <=> i2.to_s}

      converted_keys.should == orig_keys
    end

    it 'preserves value' do
      sash = Sash.new(@hash)
      converted = sash.stringify_keys

      arrays_should_be_equal sash.values, converted.values
    end
  end



  describe "#delete" do
    it 'converts Symbol key into String before deleting' do
      sash = Sash.new(@hash)

      sash.delete(:sym_key)
      sash.key?("hash").should be_false
    end

    it 'works with String keys as well' do
      sash = Sash.new(@hash)

      sash.delete("str_key")
      sash.key?("str_key").should be_false
    end
  end



  describe "#merge" do
    before(:each) do
      @sash = Sash.new(@hash).merge(:no => "in between")
    end

    it 'returns instance of Sash' do
      @sash.should be_an_instance_of(Sash)
    end

    it 'merges in give Hash' do
      @sash["no"].should == "in between"
    end
  end



  describe "#fetch" do
    before(:each) do
      @sash = Sash.new(@hash).merge(:no => "in between")
    end

    it 'converts key before fetching' do
      @sash.fetch("no").should == "in between"
    end

    it 'returns alternative value if key lookup fails' do
      @sash.fetch("flying", "screwdriver").should == "screwdriver"
    end
  end


  describe "#default" do
    before(:each) do
      @sash = Sash.new(:yet_another_technical_revolution)
    end

    it 'returns default value unless key exists in sash' do
      @sash.default("peak oil is now behind, baby").should == :yet_another_technical_revolution
    end

    it 'returns existing value if key is String and exists in sash' do
      @sash.update("no" => "in between")
      @sash.default("no").should == "in between"
    end
  end


  describe "#values_at" do
    before(:each) do
      @sash = Sash.new(@hash).merge(:no => "in between")
    end

    it 'is indifferent to whether keys are strings or symbols' do
      @sash.values_at("sym_key", :str_key, :no).should == ["symk_val", "strk_val", "in between"]
    end
  end


  describe "#symbolize_keys!" do
    it 'returns the sash itself' do
      sash = Sash.new(@hash)
      sash.symbolize_keys!.object_id.should == sash.object_id
    end
  end
end
