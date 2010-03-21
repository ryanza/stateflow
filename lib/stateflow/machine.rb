module Stateflow
  class Machine
    attr_accessor :states, :initial_state
    
    def initialize(&machine)
      @states = Hash.new
      instance_eval(&machine)
    end

    private
    def state(name, args = {})
      state = Stateflow::State.new(name)
      @initial_state = state if @states.empty? || args[:initial] == true
      @states[name.to_sym] = state
    end
  end
end