$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'stateflow'

require 'spec'
require 'spec/autorun'

Stateflow.persistence = :none

Spec::Runner.configure do |config|
end