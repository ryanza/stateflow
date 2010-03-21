module Stateflow
  def self.included(base)
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end
  
  def self.persistence
    @@persistence ||= "active_record"
  end
  
  def self.persistence=(persistence)
    @@persistence = persistence
  end
  
  module ClassMethods
    attr_reader :machine
    
    def stateflow(&block)
      @machine = Stateflow::Machine.new(&block)
      
      @machine.states.values.each do |state|
        state_name = state.name
        define_method "#{state_name}?" do
          state_name == current_state.name
        end
      end
    end
    
    def states
      @machine.states
    end
  end
  
  module InstanceMethods
    def current_state
      self.class.machine.initial_state
    end
  end
  
  autoload :Machine, 'stateflow/machine'
  autoload :State, 'stateflow/state'
end