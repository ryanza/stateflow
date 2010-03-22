module Stateflow
  class Transition
    attr_accessor :from, :to
    def initialize(args)
      @from = [args[:from]].flatten
      @to = args[:to]
    end 
  end
end