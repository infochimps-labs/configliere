require 'extlib/mash'

#
# Taken from extlib/lib/mash.rb
#
# This class has dubious semantics and we only have it so that people can write
# params[:key] instead of params['key'].
class Sash < ::Mash

  # @param key<Object> The default value for the mash. Defaults to nil.
  #
  # @details [Alternatives]
  #   If key is a Symbol and it is a key in the mash, then the default value will
  #   be set to the value matching the key.
  def default(key = nil)
    if key.is_a?(String) && include?(key = key.to_sym)
      self[key]
    else
      super
    end
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
  #   The converted key. If the key was a symbol, it will be converted to a
  #   string.
  #
  # @api private
  def convert_key(key)
    key.respond_to?(:to_sym) ? key.to_sym : key
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
