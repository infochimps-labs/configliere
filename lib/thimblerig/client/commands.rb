require 'highline/import'
module Thimblerig
  class Client

    # ===========================================================================
    #
    # Commands
    #

    # All known commands
    COMMANDS= {}

    COMMANDS[:fix] = "encrypt the thimble",
    def fix
      Log.info "Fixing stored info for #{handle}"
      store.fix!(handle, option_or_ask(:key))
    end

    COMMANDS[:delete] = "removes the thimble"
    def delete
      store.delete! handle, option_or_ask(:key)
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
      p new_hsh
      new_thimble = Thimblerig::Thimble.new(new_key, new_hsh)
      store.put! handle, new_thimble
      dump new_thimble
    end

    COMMANDS[:dump] = "print the decrypted information"
    def dump thimble
      puts "Stored info for #{handle}:"
      thimble.to_decrypted.each do |attr, val|
        puts "  %-21s\t%s"%[attr.to_s+':', val.inspect]
      end
      puts "  thimble encryption options:" unless thimble.options.blank?
      thimble.options.each do |attr, val|
        puts "    %-19s\t%s"%[attr.to_s+':', val.inspect]
      end
    end

    COMMANDS[:help] = "Show this usage info"
    def help
      puts %Q{Client for the thimblerig gem, which stores configuration info and passwords for automated scripts
Usage:
  #{File.basename($0)} command handle [--thimblefile=filename] [... name-value pairs ...]
where
  command:      one of #{COMMANDS.keys[0..-2].join(', ')} or #{COMMANDS.keys.last}
  handle:       name of the thimble to use.
#{INTERNAL_OPTIONS.map{|cmd, desc| "  %-13s %s"%[cmd.to_s+':', desc]}.join("\n") }

commands:
#{COMMANDS.map{|cmd, desc| "  %-13s %s"%[cmd.to_s+':', desc]}.join("\n") }
   }
    end

    #
    # Run the command
    #
    def run
      begin
        # Check options
        return help if options[:help] || (command == :help)
        die "Please give a command and the name of the thimble to encrypt" unless command
        die "Please give the name of the thimble to encrypt" unless handle || ([:help].include?(command))
        warn "Unknown command" unless COMMANDS.include?(command)
        #
        case command
        when :dump then dump get(handle)
        when :fix  then fix
        when :set  then set
        when :delete  then delete
        when :change_key then change_key
        else die "Can't understand command #{command}"
        end
      rescue OpenSSL::Cipher::CipherError => e
        warn "Decrypt error: wrong password for #{handle}"; exit 3
      end
    end

  end
end
