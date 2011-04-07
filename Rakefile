require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('stateflow', '0.5.0.beta') do |p|
  p.description    = "State machine that allows dynamic transitions for business workflows"
  p.url            = "http://github.com/ryanza/stateflow"
  p.author         = "Ryan Oberholzer"
  p.email          = "ryan@platform45.com"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.dependencies = ["activesupport"]
  p.development_dependencies = ["rspec >=2.0.0", "activerecord", "mongoid >=2.0.0.beta.20", "sqlite3-ruby"]
end
