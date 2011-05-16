module Configliere

  #
  # Command line tool to manage param info
  #
  # To include, specify
  #
  #   Settings.use :commands
  #
  module Commands

    # The name of the command.
    attr_accessor :command_name

    # Add a command, along with a description of its predicates and the command itself.
    def define_command cmd, options={}, &block
      cmd = cmd.to_sym
      command_configuration = Configliere::Param.new
      command_configuration.use :commandline, :env_var
      yield command_configuration if block_given?
      commands[cmd] = options.merge(:config => command_configuration)
    end

    def commands
      @commands ||= DeepHash.new
    end

    def command
      command_name && commands[command_name]
    end

    # The Param object for the command
    def command_settings
      command && command[:config]
    end

    def resolve!
      super()
      commands.each_value do |command|
        command[:config].resolve!
      end
      self
    end

    #
    # Parse the command-line args into the params hash.
    #
    # '--happy_flag'   produces :happy_flag => true in the params hash
    # '--foo=foo_val'  produces :foo => 'foo_val' in the params hash.
    # '--'             Stop parsing; all remaining args are piled into :rest
    #
    # self.rest        contains all arguments that don't start with a '--'
    #                  and all args following the '--' sentinel if any.
    #
    def process_argv!
      super()
      base, cmd = script_base_and_command
      if cmd
        self.command_name = cmd.to_sym
      elsif rest.first
        self.command_name = rest.shift.to_sym if commands.include?(rest.first.to_sym)
      end
    end

    # The script name without command appendix if any: For $0 equal to any of
    # 'git', 'git-reset', or 'git-cherry-pick', base_script_name is 'git'
    #
    def script_base_and_command
      raw_script_name.split('-', 2)
    end

    # Usage line
    def usage
      %Q{usage: #{script_base_and_command.first} [command] [...--param=val...]}
    end

    # Return help on commands.
    def commands_help
      help = ["\nAvailable commands:"]
      commands.sort.each do |cmd, info|
        help << ("  %-27s %s" % [cmd, info[:description]]) unless info[:internal]
      end
      help << "\nRun `#{script_base_and_command.first} help COMMAND' for more help on COMMAND" if commands.include?(:help)
      help.flatten.join("\n")
    end
  end

  Param.on_use(:commands) do
    use :commandline
    extend Configliere::Commands
  end
end
