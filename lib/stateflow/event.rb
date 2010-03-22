module Stateflow
  class NoTransitionFound < Exception; end
  class NoStateFound < Exception; end
  
  class Event
    attr_accessor :name, :transitions
    
    def initialize(name, &transitions)
      @name = name
      @transitions = Array.new
      
      instance_eval(&transitions)
    end
    
    def fire(current_state, klass)
      transition = @transitions.select{ |t| t.from.include? current_state.name }.first
      raise NoTransitionFound.new("No transition found for event #{@name}") if transition.nil?
      
      new_state = klass.machine.states[transition.to]
      raise NoStateFound.new("Invalid state #{transition.to.to_s} for transition.") if new_state.nil?
      
      current_state.execute_action(:exit, klass)
      klass.current_state = new_state
      new_state.execute_action(:enter, klass)
      true
    end
    
    private
    def transitions(args = {})
      transition = Stateflow::Transition.new(args)
      @transitions << transition
    end
  end
end