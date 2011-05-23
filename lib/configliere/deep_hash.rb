#
# A magical hash: allows deep-nested access and proper merging of settings from
# different sources
#
class DeepHash < Hash

  # @param constructor<Object>
  #   The default value for the DeepHash. Defaults to an empty hash.
  #   If constructor is a Hash, adopt its values.
  def initialize(constructor = {})
    if constructor.is_a?(Hash)
      super()
      update(constructor) unless constructor.empty?
    else
      super(constructor)
    end
  end

  unless method_defined?(:regular_writer) then alias_method :regular_writer, :[]=  ; end
  unless method_defined?(:regular_update) then alias_method :regular_update, :update  ; end

  # @param key<Object> The key to check for. This will be run through convert_key.
  #
  # @return [Boolean] True if the key exists in the mash.
  def key?(key)
    attr = convert_key(key)
    if attr.is_a?(Array)
      fk = attr.shift
      attr = attr.first if attr.length == 1
      super(fk) && (self[fk].key?(attr)) rescue nil
    else
      super(attr)
    end
  end

  # def include? def has_key? def member?
  alias_method :include?, :key?
  alias_method :has_key?, :key?
  alias_method :member?,  :key?

  # @param key<Object> The key to fetch. This will be run through convert_key.
  # @param *extras<Array> Default value.
  #
  # @return [Object] The value at key or the default value.
  def fetch(key, *extras)
    super(convert_key(key), *extras)
  end

  # @param *indices<Array>
  #   The keys to retrieve values for. These will be run through +convert_key+.
  #
  # @return [Array] The values at each of the provided keys
  def values_at(*indices)
    indices.collect{|key| self[convert_key(key)]}
  end

  # @param key<Object>
  #   The key to delete from the DeepHash.
  def delete attr
    attr = convert_key(attr)
    attr.is_a?(Array) ? deep_delete(*attr) : super(attr)
  end

  # @return [Hash] converts to a plain hash.
  def to_hash
    Hash.new(default).merge(self)
  end

  # @param hash<Hash> The hash to merge with the deep_hash.
  #
  # @return [DeepHash] A new deep_hash with the hash values merged in.
  def merge(hash, &block)
    self.dup.update(hash, &block)
  end

  # @param other_hash<Hash>
  #   A hash to update values in the deep_hash with. The keys and the values will be
  #   converted to DeepHash format.
  #
  # @return [DeepHash] The updated deep_hash.
  def update(other_hash, &block)
    deep_hash = self.class.new
    other_hash.each_pair do |key, value|
      val = convert_value(value)
      deep_hash[key] = val
    end
    regular_update(deep_hash, &block)
  end

  alias_method :merge!, :update

  # Allows for reverse merging two hashes where the keys in the calling hash take precedence over those
  # in the <tt>other_hash</tt>. This is particularly useful for initializing an option hash with default values:
  #
  #   def setup(options = {})
  #     options.reverse_merge! :size => 25, :velocity => 10
  #   end
  #
  # Using <tt>merge</tt>, the above example would look as follows:
  #
  #   def setup(options = {})
  #     { :size => 25, :velocity => 10 }.merge(options)
  #   end
  #
  # The default <tt>:size</tt> and <tt>:velocity</tt> are only set if the +options+ hash passed in doesn't already
  # have the respective key.
  def reverse_merge(other_hash)
    self.class.new(other_hash).merge!(self)
  end unless method_defined?(:reverse_merge)

  # Performs the opposite of <tt>merge</tt>, with the keys and values from the first hash taking precedence over the second.
  # Modifies the receiver in place.
  def reverse_merge!(other_hash)
    merge!( other_hash ){|k,o,n| convert_value(o) }
  end unless method_defined?(:reverse_merge!)

  # This DeepHash with all its keys converted to symbols, as long as they
  # respond to +to_sym+. (this is always true for a deep_hash)
  #
  # @return [DeepHash] A copy of this deep_hash.
  def symbolize_keys
    dup.symbolize_keys!
  end unless method_defined?(:symbolize_keys)

  # This DeepHash with all its keys converted to symbols, as long as they
  # respond to +to_sym+. (this is always true for a deep_hash)
  #
  # @return [DeepHash] This deep_hash unchanged.
  def symbolize_keys!; self end

  # Return a new hash with all top-level keys converted to strings.
  #
  # @return [Hash]
  def stringify_keys
    hsh = Hash.new(default)
    self.each do |key, val|
      hsh[key.to_s] = val
    end
    hsh
  end

  #
  # remove all key-value pairs where the value is nil
  #
  def compact
    reject{|key,val| val.nil? }
  end
  #
  # Replace the hash with its compacted self
  #
  def compact!
    replace(compact)
  end

  # Slice a hash to include only the given keys. This is useful for
  # limiting an options hash to valid keys before passing to a method:
  #
  #   def search(criteria = {})
  #     assert_valid_keys(:mass, :velocity, :time)
  #   end
  #
  #   search(options.slice(:mass, :velocity, :time))
  #
  # If you have an array of keys you want to limit to, you should splat them:
  #
  #   valid_keys = [:mass, :velocity, :time]
  #   search(options.slice(*valid_keys))
  def slice(*keys)
    keys = keys.map!{|key| convert_key(key) } if respond_to?(:convert_key)
    hash = self.class.new
    keys.each { |k| hash[k] = self[k] if has_key?(k) }
    hash
  end unless method_defined?(:slice)

  # Replaces the hash with only the given keys.
  # Returns a hash containing the removed key/value pairs
  # @example
  #   hsh = {:a => 1, :b => 2, :c => 3, :d => 4}
  #   hsh.slice!(:a, :b)
  #   # => {:c => 3, :d =>4}
  #   hsh
  #   # => {:a => 1, :b => 2}
  def slice!(*keys)
    keys = keys.map!{|key| convert_key(key) } if respond_to?(:convert_key)
    omit = slice(*self.keys - keys)
    hash = slice(*keys)
    replace(hash)
    omit
  end unless method_defined?(:slice!)

  # Removes the given keys from the hash
  # Returns a hash containing the removed key/value pairs
  #
  # @example
  #   hsh = {:a => 1, :b => 2, :c => 3, :d => 4}
  #   hsh.extract!(:a, :b)
  #   # => {:a => 1, :b => 2}
  #   hsh
  #   # => {:c => 3, :d =>4}
  def extract!(*keys)
    result = self.class.new
    keys.each{|key| result[key] = delete(key) }
    result
  end unless method_defined?(:extract!)

  # Validate all keys in a hash match *valid keys, raising ArgumentError on a mismatch.
  # Note that keys are NOT treated indifferently, meaning if you use strings for keys but assert symbols
  # as keys, this will fail.
  #
  # ==== Examples
  #   { :name => "Rob", :years => "28" }.assert_valid_keys(:name, :age) # => raises "ArgumentError: Unknown key(s): years"
  #   { :name => "Rob", :age => "28" }.assert_valid_keys("name", "age") # => raises "ArgumentError: Unknown key(s): name, age"
  #   { :name => "Rob", :age => "28" }.assert_valid_keys(:name, :age) # => passes, raises nothing
  def assert_valid_keys(*valid_keys)
    unknown_keys = keys - [valid_keys].flatten
    raise(ArgumentError, "Unknown key(s): #{unknown_keys.join(", ")}") unless unknown_keys.empty?
  end unless method_defined?(:assert_valid_keys)

  # Sets a member value.
  #
  # Given a deep key (one that contains '.'), uses it as a chain of hash
  # memberships. Otherwise calls the normal hash member setter
  #
  # @example
  #   foo = DeepHash.new :hi => 'there'
  #   foo['howdy.doody'] = 3
  #   foo # => { :hi => 'there', :howdy => { :doody => 3 } }
  #
  def []= attr, val
    attr = convert_key(attr)
    val  = convert_value(val)
    attr.is_a?(Array) ? deep_set(*(attr | [val])) : super(attr, val)
  end


  # Gets a member value.
  #
  # Given a deep key (one that contains '.'), uses it as a chain of hash
  # memberships. Otherwise calls the normal hash member getter
  #
  # @example
  #   foo = DeepHash.new({ :hi => 'there', :howdy => { :doody => 3 } })
  #   foo['howdy.doody'] # => 3
  #   foo['hi']          # => 'there'
  #   foo[:hi]           # => 'there'
  #
  def [] attr
    attr = convert_key(attr)
    raise if (attr == [:made])
    attr.is_a?(Array) ? deep_get(*attr) : super(attr)
  end

  # lambda for recursive merges
  ::DeepHash::DEEP_MERGER = proc do |key,v1,v2|
    if (v1.respond_to?(:update) && v2.respond_to?(:update))
      v1.update(v2.reject{|kk,vv| vv.nil? }, &DeepHash::DEEP_MERGER)
    elsif v2.nil?
      v1
    else
      v2
    end
  end unless defined?(::DeepHash::DEEP_MERGER)

  #
  # Merge hashes recursively.
  # Nothing special happens to array values
  #
  #     x = { :subhash => { :a => :val_from_x, :b => :only_in_x, :c => :only_in_x }, :scalar => :scalar_from_x}
  #     y = { :subhash => { :a => :val_from_y, :d => :only_in_y },                   :scalar => :scalar_from_y }
  #     x.deep_merge y
  #     => {:subhash=>{:a=>:val_from_y, :b=>:only_in_x, :c=>:only_in_x, :d=>:only_in_y}, :scalar=>:scalar_from_y}
  #     y.deep_merge x
  #     => {:subhash=>{:a=>:val_from_x, :b=>:only_in_x, :c=>:only_in_x, :d=>:only_in_y}, :scalar=>:scalar_from_x}
  #
  # Nil values always lose.
  #
  #     x = {:subhash=>{:nil_in_x=>nil, a=>:val_a}, :nil_in_x=>nil}
  #     y = {:subhash=>{:nil_in_x=>5},              :nil_in_x=>5}
  #     y.deep_merge x
  #     => {:subhash=>{:a=>:val_a, :nil_in_x=>5}, :nil_in_x=>5}
  #     x.deep_merge y
  #     => {:subhash=>{:a=>:val_a, :nil_in_x=>5}, :nil_in_x=>5}
  #
  def deep_merge hsh2
    merge hsh2, &DeepHash::DEEP_MERGER
  end

  def deep_merge! hsh2
    update hsh2, &DeepHash::DEEP_MERGER
    self
  end

  #
  # Treat hash as tree of hashes:
  #
  #     x = { :a => :val, :subhash => { :b => :val_b } }
  #     x.deep_set(:subhash, :cat, :hat)
  #     # => { :a => :val, :subhash => { :b => :val_b,   :cat => :hat } }
  #     x.deep_set(:subhash, :b, :newval)
  #     # => { :a => :val, :subhash => { :b => :newval, :cat => :hat } }
  #
  #
  def deep_set *args
    val      = args.pop
    last_key = args.pop
    # dig down to last subtree (building out if necessary)
    hsh = self
    args.each  do |key|
      hsh.regular_writer(key, self.class.new) unless hsh.has_key?(key)
      hsh = hsh[key]
    end
    # set leaf value
    hsh[last_key] = val
  end

  #
  # Treat hash as tree of hashes:
  #
  #     x = { :a => :val_a, :subhash => { :b => :val_b } }
  #     x.deep_get(:a)
  #     # => :val_a
  #     x.deep_get(:subhash, :c)
  #     # => nil
  #     x.deep_get(:subhash, :c, :f)
  #     # => nil
  #     x.deep_get(:subhash, :b)
  #     # => nil
  #
  def deep_get *args
    last_key = args.pop
    # dig down to last subtree (building out if necessary)
    hsh = args.inject(self){|h, k| h[k] || self.class.new }
    # get leaf value
    hsh[last_key]
  end

  #
  # Treat hash as tree of hashes:
  #
  #     x = { :a => :val, :subhash => { :a => :val1, :b => :val2 } }
  #     x.deep_delete(:subhash, :a)
  #     #=> :val
  #     x
  #     #=> { :a => :val, :subhash => { :b => :val2 } }
  #
  def deep_delete *args
    last_key  = args.pop                                   # key to delete
    last_hsh  = args.empty? ? self : (deep_get(*args)||{}) # hsh containing that key
    last_hsh.delete(last_key)
  end

protected
  # @attr key<Object> The key to convert.
  #
  # @attr [Object]
  #   The converted key. A dotted attr ('moon.cheese.type') becomes
  #   an array of sequential keys for deep_set and deep_get
  #
  # @private
  def convert_key(attr)
    case
    when attr.to_s.include?('.')   then attr.to_s.split(".").map{|sub_attr| sub_attr.to_sym }
    when attr.is_a?(Array)         then attr.map{|sub_attr| sub_attr.to_sym }
    else                                attr.to_sym
    end
  end


  # @param value<Object> The value to convert.
  #
  # @return [Object]
  #   The converted value. A Hash or an Array of hashes, will be converted to
  #   their DeepHash equivalents.
  #
  # @private
  def convert_value(value)
    if value.class == Hash   then self.class.new(value)
    elsif value.is_a?(Array) then value.collect{|e| convert_value(e) }
    else                          value
    end
  end

end
