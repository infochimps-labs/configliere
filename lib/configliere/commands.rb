Configliere.use :commandline
module Configliere

  #
  # Command line tool to manage param info
  #
  # To include, specify
  #
  #   Configliere.use :commands
  #
  module Commands

    # The name of the command.
    attr_accessor :command_name

    # Add a command, along with a description of its predicates and the command itself.
    def define_command cmd, options={}, &block
      command_configuration = Configliere.new
      yield command_configuration if block_given?
      commands[cmd] = options.merge(:config => command_configuration)
    end

    # Define a help command.
    def define_help_command!
      define_command :help, :description => "Print detailed help on each command"
    end

    # Are there any commands that have been defined?
    def commands?
      (! commands.empty?)
    end
    
    # Is +cmd+ the name of a known command?
    def command? cmd
      return false if cmd.blank?
      commands.include?(cmd) || commands.include?(cmd.to_s)
    end

    def commands
      @commands ||= Sash.new
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
      if raw_script_name =~ /(\w+)-([\w\-]+)/
        self.command_name = $2
      else
        self.command_name = rest.shift if command?(rest.first)
      end
    end

    # The script name without command appendix if any: For $0 equal to any of
    # 'git', 'git-reset', or 'git-cherry-pick', base_script_name is 'git'
    #
    def base_script_name
      raw_script_name.gsub(/-.*/, '')
    end

    # Usage line
    def usage
      %Q{usage: #{base_script_name} command [...--param=val...]}
    end

    # Return help on commands.
    def dump_command_help
      help = ["Available commands"]
      help += commands.keys.map(&:to_s).sort.map do |key|
        "  %-27s %s" % [key.to_s, commands[key][:description]] unless commands[key][:no_help]
      end
      help += ["\nRun `#{base_script_name} help COMMAND' for more help on COMMAND"] if command?(:help)
      $stderr.puts help.join("\n")
    end
    
  end

  Param.class_eval do
    # include command syntax methods in chain.  Since commandline is required
    # first at the top of this file, Commands methods sit below
    # Commandline methods in the superclass chain.
    include Commands
  end
end
