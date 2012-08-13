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

    #
    # FIXME: this will be refactored to look like Configliere::Define
    #

    # Add a command, along with a description of its predicates and the command itself.
    def define_command cmd, options={}, &block
      cmd = cmd.to_sym
      command_configuration = Configliere::Param.new
      command_configuration.use :commandline, :env_var
      yield command_configuration if block_given?
      commands[cmd] = options
      commands[cmd][:config] = command_configuration
      commands[cmd]
    end

    def commands
      @commands ||= DeepHash.new
    end

    def command_info
      commands[command_name] if command_name
    end

    def resolve!
      super()
      commands.each do |cmd, cmd_info|
        cmd_info[:config].resolve!
      end
      if command_name && commands[command_name]
        sub_config = commands[command_name][:config]
        adoptable  = sub_config.send(:definitions).keys
        merge!( Hash[sub_config.select{|k,v| adoptable.include?(k) }] )
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
      elsif (not rest.empty?) && commands.include?(rest.first.to_sym)
        self.command_name = rest.shift.to_sym
      end
    end

    # Usage line
    def usage
      %Q{usage: #{script_base_and_command.first} [command] [...--param=val...]}
    end

 protected

    # Return help on commands.
    def commands_help
      help = ["\nAvailable commands:"]
      commands.sort_by(&:to_s).each do |cmd, info|
        help << ("  %-27s %s" % [cmd, info[:description]]) unless info[:internal]
        info[:config].param_lines[1..-1].each{|line| help << "    #{line}" } rescue nil
      end
      help << "\nRun `#{script_base_and_command.first} help COMMAND' for more help on COMMAND" if commands.include?(:help)
      help.flatten.join("\n")
    end

    # The script name without command appendix if any: For $0 equal to any of
    # 'git', 'git-reset', or 'git-cherry-pick', base_script_name is 'git'
    #
    def script_base_and_command
      raw_script_name.split('-', 2)
    end
  end

  Param.on_use(:commands) do
    use :commandline
    extend Configliere::Commands
  end
end
