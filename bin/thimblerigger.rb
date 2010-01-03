#!/usr/bin/env ruby
require 'rubygems' ; $: << File.dirname(__FILE__)+'/../lib'
require 'thimblerig'
require 'thimblerig/client'
require 'thimblerig/client/commands'
Log = Logger.new(STDERR) unless defined?(Log)

class Thimblerigger < Thimblerig::CommandClient
  def usage
    %Q{Client for the thimblerig gem: manipulate configuration and passwords for automated scripts

usage: #{File.basename($0)} command handle [...--option=val...]
where
  command:             One of: #{COMMANDS.keys[0..-2].join(', ')} or #{COMMANDS.keys.last}
  handle:              Name of the thimble to use.

Configuration taken from #{thimble_file} by default.}
    end

  def process_options! *args
    super *args
    self.command = options[:_rest].shift.to_sym rescue nil
    self.handle  = options[:_rest].shift.to_sym rescue nil
    self.thimble_options = {}
    thimble_options[:hostname]   = options.delete(:hostname_in_key)
    thimble_options[:macaddr]    = options.delete(:macaddr_in_key)
    thimble_options.compact!
  end


    # ===========================================================================
    #
    # Commands
    #

    COMMANDS[:fix] = "encrypt the thimble"
    def fix
      Log.info "Fixing stored info for #{handle}"
      store.fix!(handle, option_or_ask(:key))
    end
    COMMANDS[:encrypt] = "synonym for fix. Thimbles are stored encrypted by default"
    def encrypt() fix end

    COMMANDS[:decrypt] = "Store the thimble as decrypted back into the file. Can be undone with 'fix'."
    def decrypt
      Log.info "Storing info for #{handle} in **DECRYPTED** form."
      thimble = get(handle)
      store.put_decrypted!(handle, thimble)
    end

    COMMANDS[:list] = "Show all thimbles in the thimblerig file."
    def list
      puts "List of thimble names: #{store.thimble_handles.inspect}"
    end

    COMMANDS[:delete] = "Permanently deletes the thimble"
    def delete
      Log.info "Permanently deleting stored info for #{handle}. O, I die, Horatio."
      store.delete! handle, options[:key]
    end

    COMMANDS[:set] = "sets values using remaining arguments from the command line. eg #{File.basename($0)} set my_program --username=bob --password=frank"
    def set
      thimble = get(handle)
      thimble.merge! external_options
      store.put handle, thimble
      store.save!
      Log.info "Stored configuration for #{handle}: #{thimble}"
    end

    COMMANDS[:change_key] = "set a new key and/or new key options. Specify the old key as usual with --key='...' and the new one with --new_key='...'"
    def change_key
      thimble = get(handle)
      new_key = option_or_ask(:new_key)
      new_hsh = thimble.to_decrypted.merge(thimble.internals)
      new_hsh.merge!(:_thimble_options => thimble.options.merge(thimble_options))
      new_thimble = Thimblerig::Thimble.new(new_key, new_hsh)
      store.put! handle, new_thimble
      Log.info "Changed thimble key for #{handle}: #{new_thimble}"
    end

    COMMANDS[:dump] = "print the decrypted information"
    def dump
      thimble = get(handle)
      puts "Stored info for #{handle}:\n  #{thimble.to_s}"
    end

end

Thimblerigger.new.run
