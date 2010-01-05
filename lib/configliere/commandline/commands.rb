require 'logger'
Log = Logger.new(STDERR) unless defined?(Log)
module Configliere
  class CommandClient < Client
    attr_accessor :command
    COMMANDS[:help] = "Show this usage info"

    def usage
      %Q{usage: #{File.basename($0)} command [...--option=val...]
where
  command:             One of: #{COMMANDS.keys[0..-2].join(', ')} or #{COMMANDS.keys.last}

Configuration taken from #{configliere_file} by default.}
    end

    #
    # Run the command
    #
    def run
      dump_help_if_requested
      # Check options
      die "Please give a command and the name of the configliere group to encrypt" unless command
      die "Please give the name of the configliere group to encrypt" unless handle || ([:help, :list].include?(command))
      die "\n**\nUnknown command\n**\n" unless COMMANDS.include?(command)
      #
      self.send(command)
    end

  end
end
