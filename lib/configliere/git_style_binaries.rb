require 'configliere/commandline'
module Configliere

  # If your script uses the 'script_name verb [...params...]'
  # pattern, list the commands here:
  Configliere::COMMANDS = []

  # Add a command, along with a description of its predicates and the command itself.
  def self.define_command cmd, preds_desc=nil, desc=nil
    Configliere::COMMANDS << [cmd, preds_desc, (desc || "#{cmd} command")]
  end

  #
  # Command line tool to manage param info
  #
  # To include, specify
  #
  #   Configliere.use :git_style_binaries
  #
  module GitStyleBinaries
    attr_accessor :command

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
      super
      if raw_script_name =~ /(\w+)-([\w\-]+)/
        self.command = $2
      else
        self.command = rest.shift
      end
    end

    # The script name without command appendix if any: For $0 equal to any of
    # 'git', 'git-reset', or 'git-cherry-pick', base_script_name is 'git'
    #
    def base_script_name
      raw_script_name.gsub(/-.*/, '')
    end

    # The contents of the help message.  Dumps the standard commandline help
    # message, and then lists the commands with their description.
    def help
      help_str = super()
      help_str << "\n\nCommands:\n"
      COMMANDS.map do |cmd, cmd_params, desc|
        cmd_template = "  %-49s" % [base_script_name, cmd, cmd_params].join(" ")
        cmd_template += " :: " + desc if desc
        help_str << cmd_template+"\n"
      end
      help_str
    end

    # Usage line
    def usage
      %Q{usage: #{base_script_name} command [...--param=val...]}
    end
  end

  Param.class_eval do
    # include command syntax methods in chain.  Since commandline is required
    # first at the top of this file, GitStyleBinaries methods sit below
    # Commandline methods in the superclass chain.
    include GitStyleBinaries
  end
end
