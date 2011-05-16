# Settings.use :prompt
# you must install the highline gem

require 'highline/import'
module Configliere
  #
  # Method to prompt for
  #
  module Prompt

    # Retrieve the given param, or prompt for it
    def prompt_for attr, hint=nil
      return self[attr] if has_key?(attr)
      hint ||= definition_of(attr, :description)
      hint   = " (#{hint})" if hint
      self[attr] = ask("#{attr}#{hint}? ")
    end
  end

  Param.on_use(:prompt) do
    extend Configliere::Prompt
  end
end
