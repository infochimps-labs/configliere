$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'tempfile'
# module Configliere ; DEFAULT_FILE = Tempfile.new("configliere_spec-") ;DEFAULT_FILE.close(false) ; DEFAULT_CONFIG_FILE = DEFAULT_FILE.path ; end

require 'configliere'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|

end

# Configliere::DEFAULT_FILE.close!

