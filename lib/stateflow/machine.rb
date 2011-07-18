module Stateflow
  class Machine
    attr_accessor :states, :initial_state, :events
    
    def initialize(&machine)
      @states, @events, @create_scopes = Hash.new, Hash.new, true
      instance_eval(&machine)
    end
    
    def state_column(name = :state)
      @state_column ||= name
    end
    
    def create_scopes(bool = false)
      @create_scopes = bool
    end
    
    def create_scopes?
      @create_scopes
    end

    private    
    def initial(name)
      @initial_state_name = name
    end
    
    def state(*names, &options)
      names.each do |name|
        state = Stateflow::State.new(name, &options)
        @initial_state = state if @states.empty? || @initial_state_name == name
        @states[name.to_sym] = state
      end
    end
    
    def event(name, &transitions)
      event = Stateflow::Event.new(name, self, &transitions)
      @events[name.to_sym] = event
    end
  end
end
