require 'configliere/core_ext/hash'

#
# Hash with indifferent access
#
# Adapted from extlib/lib/mash.rb
#
class Sash < ::Hash

  # @param constructor<Object>
  #   The default value for the mash. Defaults to an empty hash.
  #
  # @details [Alternatives]
  #   If constructor is a Hash, a new mash will be created based on the keys of
  #   the hash and no default value will be set.
  def initialize(constructor = {})
    if constructor.is_a?(Hash)
      super()
      update(constructor) unless constructor.empty?
    else
      super(constructor)
    end
  end 

  alias_method :regular_writer, :[]=    unless method_defined?(:regular_writer)
  alias_method :regular_update, :update unless method_defined?(:regular_update)

  # @param key<Object> The key to set.
  # @param value<Object>
  #   The value to set the key to.
  #
  # @see Mash#convert_key
  # @see Mash#convert_value
  def []=(key, value)
    regular_writer(convert_key(key), convert_value(value))
  end

  alias_method :merge!, :update

  # @param key<Object> The key to check for. This will be run through convert_key.
  #
  # @return [Boolean] True if the key exists in the mash.
  def key?(key)
    super(convert_key(key))
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

  # @param hash<Hash> The hash to merge with the mash.
  #
  # @return [Mash] A new mash with the hash values merged in.
  def merge(hash, &block)
    self.dup.update(hash, &block)
  end

  # @param key<Object>
  #   The key to delete from the mash.\
  def delete(key)
    super(convert_key(key))
  end

  # @return [Hash] The mash as a Hash with string keys.
  def to_hash
    Hash.new(default).merge(self)
  end

  # @param key<Object> The default value for the mash. Defaults to nil.
  #
  # @details [Alternatives]
  #   If key is a Symbol and it is a key in the mash, then the default value will
  #   be set to the value matching the key.
  def default(key = nil)
    if key.is_a?(String) && include?(key = key.to_sym)
      self[key]
    else
      super(key)
    end
  end

  # @param other_hash<Hash>
  #   A hash to update values in the mash with. The keys and the values will be
  #   converted to Mash format.
  #
  # @return [Mash] The updated mash.
  def update(other_hash, &block)
    sash = self.class.new
    other_hash.each_pair do |key, value|
      val = convert_value(value)
      sash[convert_key(key)] = val
    end
    regular_update(sash, &block)
  end

  # Used to provide the same interface as Hash.
  #
  # @return [Sash] This sash unchanged.
  def symbolize_keys!; self end

  # @return [Hash] The sash as a Hash with stringified keys.
  def stringify_keys
    h = Hash.new(default)
    each { |key, val| h[key.to_sym] = val }
    h
  end

protected
  # @param key<Object> The key to convert.
  #
  # @param [Object]
  #   The converted key. If the key was a string, it will be converted to a
  #   symbol.
  #
  # @api private
  def convert_key(key)
    key.is_a?(String) ? key.to_sym : key
  end

  # @param value<Object> The value to convert.
  #
  # @return [Object]
  #   The converted value. A Hash or an Array of hashes, will be converted to
  #   their Mash equivalents.
  #
  # @api private
  def convert_value(value)
    if value.class == Hash
      value.to_sash
    elsif value.is_a?(Array)
      value.collect { |e| convert_value(e) }
    else
      value
    end
  end
end


class ::Hash

  # Convert to Sash. This class has semantics of ActiveSupport's
  # HashWithIndifferentAccess and we only have it so that people can write
  # params[:key] instead of params['key'].
  #
  # @return [Mash] This hash as a Mash for string or symbol key access.
  def to_sash
    hash = Sash.new(self)
    hash.default = default
    hash
  end
  
end
