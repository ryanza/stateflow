require 'rubygems'
require 'stateflow'

class Robot
  include Stateflow
  
  stateflow do
    initial :green
    
    state :green, :yellow, :red
    
    event :change_color do
      transitions :from => :green, :to => :yellow
      transitions :from => :yellow, :to => :red
      transitions :from => :red, :to => :green
    end
  end
end  