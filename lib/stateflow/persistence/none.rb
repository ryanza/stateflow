module Stateflow
  module Persistence
    module None
      def self.install(base)
        base.send :include, InstanceMethods
      end
      
      module InstanceMethods
        attr_accessor :state
        
        def load_from_persistence
          @state
        end

        def save_to_persistence(new_state, options)
          @state = new_state
        end
      end
    end
  end
end
