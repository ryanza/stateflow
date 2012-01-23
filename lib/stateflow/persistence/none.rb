module Stateflow
  module Persistence
    module None
      extend ActiveSupport::Concern
      
      module ClassMethods
        def add_scope(state)
          # do nothing
        end
      end

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
