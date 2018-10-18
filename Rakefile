require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('stateflow', '0.6.0') do |p|
  p.description    = "State machine that allows dynamic transitions for business workflows"
  p.url            = "http://github.com/ryanza/stateflow"
  p.author         = "Ryan Oberholzer"
  p.email          = "ryan@madlabs.tech"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.dependencies = ["activesupport"]
  p.development_dependencies = ["rspec >=2.0.0", "activerecord", "mongoid >=2.0.0.beta.20", "sqlite3-ruby"]
end
