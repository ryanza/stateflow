module Stateflow
  def self.included(base)
    base.send :include, InstanceMethods
    base.extend ClassMethods
    Stateflow::Persistence.set(base)
  end
  
  def self.persistence
    @@persistence ||= :active_record
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
      
      @machine.events.keys.each do |key|
        define_method "#{key}!" do
          fire_event(key)
        end
      end
    end
  end
  
  module InstanceMethods
    def current_state  
      @current_state ||= load_from_persistence.nil? ? machine.initial_state : machine.states[load_from_persistence.to_sym]
    end
    
    def previous_state  
      @previous_state ||= load_previous_from_persistence.nil? ? nil : machine.states[load_previous_from_persistence.to_sym]
    end
    
    def previous_state=(old_state)
      save_previous_to_persistence(old_state.name.to_s)
      @previous_state = old_state
    end
    
    def current_state=(new_state)
      save_to_persistence(new_state.name.to_s)
      @current_state = new_state
    end
    
    def machine
      self.class.machine
    end
    
    private
    def fire_event(event_name)
      event = machine.events[event_name.to_sym]
      raise Stateflow::NoEventFound.new("No event matches #{event_name}") if event.nil?
      event.fire(current_state, self)
    end
  end
  
  autoload :Machine, 'stateflow/machine'
  autoload :State, 'stateflow/state'
  autoload :Event, 'stateflow/event'
  autoload :Transition, 'stateflow/transition'
  autoload :Persistence, 'stateflow/persistence'
  autoload :Exception, 'stateflow/exception'
end
