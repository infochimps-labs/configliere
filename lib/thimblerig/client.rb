require 'thimblerig/client/options'
module Thimblerig
  #
  # Command line tool to manage thimble info
  #
  class Client
    attr_accessor :handle
    def initialize handle=nil
      self.handle  = handle
      self.options = {}
      process_options!
      dump_help_if_requested
      self.store = Thimblerig::ThimbleStore.new(thimble_file)
    end

    # Filename of thimble file
    def thimble_file
      options[:thimble_file] || Thimblerig::DEFAULT_FILENAME
    end

    # get the thimble for the given handle
    def get handle, key=nil, options=nil
      begin
        store.get(handle, key || option_or_ask(:key, handle))
      rescue OpenSSL::Cipher::CipherError => e
        warn "Decrypt error: wrong password for #{handle}"; exit 3
      end
    end

    def help
      help_str = [
        usage,
        "\nOptions:",  INTERNAL_OPTIONS.map{|cmd, desc| "  %-20s %s"%[cmd.to_s+':', desc]}.join("\n"), ]
      help_str += [
        "\nCommands", COMMANDS.map{|cmd, desc| "  %-20s %s"%[cmd.to_s+':', desc]}.join("\n")] unless COMMANDS.empty?
      help_str.join("\n")
    end

    # Usage line
    def usage
      %Q{usage: #{File.basename($0)} [...--option=val...]

Configuration taken from #{thimble_file} by default.}
    end

    # Ouput the help string if requested
    def dump_help_if_requested
      return unless options[:help]
      $stderr.puts help
      exit
    end
  end
end
