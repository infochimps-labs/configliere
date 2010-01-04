$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'tempfile'
module Thimblerig ; DEFAULT_FILE = Tempfile.new("thimblerig_spec-") ;DEFAULT_FILE.close(false) ; DEFAULT_FILENAME = DEFAULT_FILE.path ; end

require 'thimblerig'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|

end

Thimblerig::DEFAULT_FILE.close!

