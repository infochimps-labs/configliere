#
# core_ext/hash.rb -- hash extensions
#
class Hash

  # lambda for recursive merges
  Hash::DEEP_MERGER = proc do |key,v1,v2|
    (v1.respond_to?(:merge) && v2.respond_to?(:merge)) ? v1.merge(v2.compact, &Hash::DEEP_MERGER) : (v2.nil? ? v1 : v2)
  end

  #
  # Merge hashes recursively.
  # Nothing special happens to array values
  #
  #     x = { :subhash => { 1 => :val_from_x, 222 => :only_in_x, 333 => :only_in_x }, :scalar => :scalar_from_x}
  #     y = { :subhash => { 1 => :val_from_y, 999 => :only_in_y },                    :scalar => :scalar_from_y }
  #     x.deep_merge y
  #     => {:subhash=>{1=>:val_from_y, 222=>:only_in_x, 333=>:only_in_x, 999=>:only_in_y}, :scalar=>:scalar_from_y}
  #     y.deep_merge x
  #     => {:subhash=>{1=>:val_from_x, 222=>:only_in_x, 333=>:only_in_x, 999=>:only_in_y}, :scalar=>:scalar_from_x}
  #
  # Nil values always lose.
  #
  #     x = {:subhash=>{:nil_in_x=>nil, 1=>:val1,}, :nil_in_x=>nil}
  #     y = {:subhash=>{:nil_in_x=>5},              :nil_in_x=>5}
  #     y.deep_merge x
  #     => {:subhash=>{1=>:val1, :nil_in_x=>5}, :nil_in_x=>5}
  #     x.deep_merge y
  #     => {:subhash=>{1=>:val1, :nil_in_x=>5}, :nil_in_x=>5}
  #
  def deep_merge hsh2
    merge hsh2, &Hash::DEEP_MERGER
  end

  def deep_merge! hsh2
    merge! hsh2, &Hash::DEEP_MERGER
  end

  #
  # Treat hash as tree of hashes:
  #
  #     x = { 1 => :val, :subhash => { 1 => :val1 } }
  #     x.deep_set(:subhash, :cat, :hat)
  #     # => { 1 => :val, :subhash => { 1 => :val1,   :cat => :hat } }
  #     x.deep_set(:subhash, 1, :newval)
  #     # => { 1 => :val, :subhash => { 1 => :newval, :cat => :hat } }
  #
  #
  def deep_set *args
    val      = args.pop
    last_key = args.pop
    # dig down to last subtree (building out if necessary)
    hsh = args.empty? ? self : args.inject(self){|hsh, key| hsh[key] ||= {} }
    # set leaf value
    hsh[last_key] = val
  end

  #
  # Treat hash as tree of hashes:
  #
  #     x = { 1 => :val, :subhash => { 1 => :val1 } }
  #     x.deep_get(:subhash, 1)
  #     # => :val
  #     x.deep_get(:subhash, 2)
  #     # => nil
  #     x.deep_get(:subhash, 2, 3)
  #     # => nil
  #     x.deep_get(:subhash, 2)
  #     # => nil
  #
  def deep_get *args
    last_key = args.pop
    # dig down to last subtree (building out if necessary)
    hsh = args.inject(self){|hsh, key| hsh[key] || {} }
    # get leaf value
    hsh[last_key]
  end

  def deep_delete *args
    last_key  = args.pop
    last_hsh  = args.empty? ? self : (deep_get(*args)||{})
    last_hsh.delete(last_key)
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

end
