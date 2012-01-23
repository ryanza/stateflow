module Stateflow
  module Persistence
    module Mongoid
      extend ActiveSupport::Concern
      
      included do |base|
        base.before_validation(:ensure_initial_state, :on => :create)
      end

      module ClassMethods
        def add_scope(state)
          scope state.name, where(:state => state.name.to_s)
        end
      end
      
      def load_from_persistence
        send machine.state_column.to_sym
      end

      def save_to_persistence(new_state, options = {})
        send("#{machine.state_column}=".to_sym, new_state)
        save if options[:save]
      end

      def ensure_initial_state
        send("#{machine.state_column.to_s}=", current_state.name.to_s) if send(machine.state_column.to_s).blank?
      end
    end
  end
end
