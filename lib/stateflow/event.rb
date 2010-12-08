module Stateflow
  class Event
    attr_accessor :name, :transitions, :machine
    
    def initialize(name, machine=nil, &transitions)
      @name = name
      @machine = machine
      @transitions = Array.new
      
      instance_eval(&transitions)
    end
    
    def fire(current_state, klass, options)
      transition = @transitions.select{ |t| t.from.include? current_state.name }.first
      raise NoTransitionFound.new("No transition found for event #{@name}") if transition.nil?
      
      return false unless transition.can_transition?(klass)
      
      new_state = klass.machine.states[transition.find_to_state(klass)]
      raise NoStateFound.new("Invalid state #{transition.to.to_s} for transition.") if new_state.nil?
      
      current_state.execute_action(:exit, klass)
      klass.set_current_state(new_state, options)
      
      klass._previous_state = current_state.name.to_s
      new_state.execute_action(:enter, klass)
      true
    end
    
    private
    def transitions(args = {})
      transition = Stateflow::Transition.new(args)
      @transitions << transition
    end
    
    def any
      @machine.states.keys
    end
  end
end
