module Stateflow
  class State
    attr_accessor :name, :options

    def initialize(name, &options)
      @name = name
      @options = Hash.new

      instance_eval(&options) if block_given?
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

    def before_enter(method=nil,&block)
      @options[:before_enter] = method || block
    end
    alias enter before_enter

    def after_enter(method=nil,&block)
      @options[:after_enter]  = method || block
    end

    def before_exit(method=nil,&block)
      @options[:before_exit]  = method || block
    end
    alias exit before_exit

    def after_exit(method=nil,&block)
      @options[:after_exit]   = method || block
    end
  end
end
