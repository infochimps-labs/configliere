require 'configliere/client/options'
module Configliere
  #
  # Command line tool to manage param info
  #
  class Client
    attr_accessor :handle
    def initialize handle=nil
      self.handle  = handle
      self.options = {}
      process_options!
      dump_help_if_requested
      self.store = Configliere::ParamStore.new(configliere_file)
    end

    # Filename of configliere file
    def configliere_file
      options[:configliere_file] || Configliere::DEFAULT_FILENAME
    end

    # get the param for the given handle
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

Configuration taken from #{configliere_file} by default.}
    end

    # Ouput the help string if requested
    def dump_help_if_requested
      return unless options[:help]
      $stderr.puts help
      exit
    end
  end
end
