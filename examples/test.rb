require 'rubygems'
require 'stateflow'

class Test
  include Stateflow
  
  stateflow do
    
    initial :love
    
    state :love do
      enter lambda { |t| p "Entering love" }
      exit :exit_love
    end
    
    state :hate do
      enter lambda { |t| p "Entering hate" }
      exit lambda { |t| p "Exiting hate" }
    end
    
    state :mixed do
      enter lambda { |t| p "Entering mixed" }
      exit lambda { |t| p "Exiting mixed" }
    end
    
    event :b do
      transitions :from => :love, :to => :hate, :if => :no_ice_cream
      transitions :from => :hate, :to => :love
    end
    
    event :a do
      transitions :from => :love, :to => [:hate, :mixed], :decide => :likes_ice_cream?
      transitions :from => [:hate, :mixed], :to => :love
    end
  end
  
  def likes_ice_cream?
    rand(10) > 5 ? :mixed : :hate
  end
  
  def exit_love
    p "Exiting love"
  end
  
  def no_ice_cream
    rand(4) > 2 ? true : false
  end
end
