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
      no_transition_found(current_state.name) if transition.nil?

      return false unless transition.can_transition?(klass)

      new_state = klass.machine.states[transition.find_to_state(klass)]
      no_state_found(transition.to) if new_state.nil?

      current_state.execute_action(:exit, klass)
      klass._previous_state = current_state.name.to_s
      new_state.execute_action(:enter, klass)

      klass.set_current_state(new_state, options)
      true
    end

    private

    def transition_missing(&block)
      @transition_missing = block
    end

    def no_transition_found(from_state)
      raise NoTransitionFound.new("No transition found for event #{@name}") unless @transition_missing
      @transition_missing.call(from_state)
    end

    def no_state_found(target_state)
      NoStateFound.new("Invalid state #{target_state.to_s} for transition.")
    end

    def transitions(args = {})
      transition = Stateflow::Transition.new(args)
      @transitions << transition
    end

    def any
      @machine.states.keys
    end
  end
end
