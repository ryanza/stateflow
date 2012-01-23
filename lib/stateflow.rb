require 'active_support'
require 'active_support/inflector'

module Stateflow
  extend ActiveSupport::Concern
  
  included do |base|
    Stateflow::Persistence.load!(base)
  end
  
  def self.persistence
    @@persistence ||= nil
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
        add_scope state if @machine.create_scopes?
      end
      
      @machine.events.keys.each do |key|
        define_method "#{key}" do
          fire_event(key, :save => false)
        end
        
        define_method "#{key}!" do
          fire_event(key, :save => true)
        end
      end
    end
  end
  
  attr_accessor :_previous_state
  
  def current_state  
    @current_state ||= load_from_persistence.nil? ? machine.initial_state : machine.states[load_from_persistence.to_sym]
  end
  
  def set_current_state(new_state, options = {})
    save_to_persistence(new_state.name.to_s, options)
    @current_state = new_state
  end
  
  def machine
    self.class.machine
  end
  
  def available_states
    machine.states.keys
  end
  
  private
  def fire_event(event_name, options = {})
    event = machine.events[event_name.to_sym]
    raise Stateflow::NoEventFound.new("No event matches #{event_name}") if event.nil?
    event.fire(current_state, self, options)
  end
  
  autoload :Machine, 'stateflow/machine'
  autoload :State, 'stateflow/state'
  autoload :Event, 'stateflow/event'
  autoload :Transition, 'stateflow/transition'
  autoload :Persistence, 'stateflow/persistence'
  autoload :Exception, 'stateflow/exception'
end

require 'stateflow/railtie' if defined?(Rails)
