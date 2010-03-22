module Stateflow
  class IncorrectTransition < Exception; end
  
  class Transition
    attr_reader :from, :to, :if, :decide
    
    def initialize(args)
      @from = [args[:from]].flatten
      @to = args[:to]
      @if = args[:if]
      @decide = args[:decide]
    end 
    
    def can_transition?(base)
      return true unless @if
      execute_action(@if, base)
    end
    
    def find_to_state(base)
      raise IncorrectTransition.new("Array of destinations and no decision") if @to.is_a?(Array) && @decide.nil?
      return @to unless @to.is_a?(Array)
      
      to = execute_action(@decide, base)
      
      @to.include?(to) ? to : (raise NoStateFound.new("Decision did not return a state that was set in the 'to' argument"))
    end
      
    private
    def execute_action(action, base)
      case action
      when Symbol, String
        base.send(action)
      when Proc
        action.call(base)
      end
    end
  end
end