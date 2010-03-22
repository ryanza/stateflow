module Stateflow
  class State
    attr_accessor :name, :options
    
    def initialize(name, &options)
      @name = name
      @options = Hash.new
      
      instance_eval(&options) if options
    end
    
    def enter(method = nil, &block)
      @options[:enter] = method.nil? ? block : method
    end
    
    def exit(method = nil, &block)
      @options[:exit] = method.nil? ? block : method
    end
    
    def execute_action(action, base)
      action = @options[action.to_sym]
      
      case action
      when Symbol, String
        base.send(action)
      when Proc
        action.call(base)
      end
    end
  end
end