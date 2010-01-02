require 'logger'
Log = Logger.new(STDERR) unless defined?(Log)
module Thimblerig
  class Client
    attr_accessor :command

    # ===========================================================================
    #
    # Commands
    #

    COMMANDS[:fix] = "encrypt the thimble"
    COMMANDS[:encrypt] = "synonym for fix. Thimbles are stored encrypted by default"
    def fix
      Log.info "Fixing stored info for #{handle}"
      store.fix!(handle, option_or_ask(:key))
    end

    COMMANDS[:decrypt] = "Store the thimble as decrypted back into the file. Can be undone with 'fix'."
    def decrypt
      Log.info "Storing info for #{handle} in **DECRYPTED** form."
      thimble = get(handle)
      store.put_decrypted!(handle, thimble)
    end

    COMMANDS[:list] = "Show all thimbles in the thimblerig file."
    def list
      puts "List of thimble names: #{store.handles.inspect}"
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
      dump thimble
    end

    COMMANDS[:change_key] = "set a new key and/or new key options. Specify the old key as usual with --key='...' and the new one with --new_key='...'"
    def change_key
      thimble = get(handle)
      new_key = option_or_ask(:new_key)
      new_hsh = thimble.to_decrypted.merge(thimble.internals)
      new_hsh.merge!(:_thimble_options => thimble.options.merge(thimble_options))
      new_thimble = Thimblerig::Thimble.new(new_key, new_hsh)
      store.put! handle, new_thimble
      dump new_thimble
    end

    COMMANDS[:dump] = "print the decrypted information"
    def dump thimble
      puts "Stored info for #{handle}:\n  #{thimble.to_s}"
    end

    COMMANDS[:help] = "Show this usage info"
    def usage
      %Q{#{File.basename($0)} command handle [... name-value pairs ...]
where
  command:             One of: #{COMMANDS.keys[0..-2].join(', ')} or #{COMMANDS.keys.last}
  handle:              Name of the thimble to use. }
    end

    #
    # Run the command
    #
    def run
      dump_help_if_requested
      # Check options
      die "Please give a command and the name of the thimble to encrypt" unless command
      die "Please give the name of the thimble to encrypt" unless handle || ([:help, :list].include?(command))
      warn "Unknown command" unless COMMANDS.include?(command)
      #
      case command
      when :dump       then dump get(handle)
      when :fix        then fix
      when :encrypt    then fix
      when :list       then list
      when :set        then set
      when :delete     then delete
      when :change_key then change_key
      when :decrypt    then decrypt
      else die "Can't understand command #{command}"
      end
    end

  end
end
