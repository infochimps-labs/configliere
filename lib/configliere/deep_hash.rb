#
# core_ext/hash.rb -- hash extensions
#
class DeepHash < Hash

  # lambda for recursive merges
  ::DeepHash::DEEP_MERGER = proc do |key,v1,v2|
    if (v1.respond_to?(:merge) && v2.respond_to?(:merge))
      v1.merge(v2.reject{|key,val| val.nil? }, &DeepHash::DEEP_MERGER)
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
    merge hsh2, &DeepHash::DEEP_MERGER
  end

  def deep_merge! hsh2
    update hsh2, &DeepHash::DEEP_MERGER
    self
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
    hsh = self
    args.each{|key| hsh = (hsh[key] ||= self.class.new) }
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
    hsh = args.inject(self){|h, k| h[k] || self.class.new }
    # get leaf value
    hsh[last_key]
  end

  #
  # Treat hash as tree of hashes:
  #
  #     x = { 1 => :val, :subhash => { 1 => :val1, 2 => :val2 } }
  #     x.deep_delete(:subhash, 1)
  #     #=> :val
  #     x
  #     #=> { 1 => :val, :subhash => { 2 => :val2 } }
  #
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
