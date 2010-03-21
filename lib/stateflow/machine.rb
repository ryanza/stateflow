module Stateflow
  class Machine
    attr_accessor :states, :initial_state
    
    def initialize(&machine)
      @states = Hash.new
      instance_eval(&machine)
    end

    private
    def state(*names, &block)
      names.each do |name|
        state = Stateflow::State.new(name, &block)
        @initial_state = state if @states.empty? && @initial_state.nil?
        @states[name.to_sym] = state
      end
    end
    
    def initial(name)
      @initial_state = name.to_sym
    end
  end
end