module Stateflow
  module Persistence
    module Mongoid
      def self.install(base)
        base.respond_to?(:before_validation_on_create) ? base.before_validation_on_create(:ensure_initial_state) : base.before_validation(:ensure_initial_state, :on => :create)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        def load_from_persistence
          self.read_attribute(machine.state_column.to_sym)
        end
        
        def save_to_persistence(new_state)
          self.update_attributes(machine.state_column.to_sym => new_state)
        end
        
        def load_previous_from_persistence
          self.read_attribute(machine.previous_state_column.to_sym) if machine.previous_state_column
        end

        def save_previous_to_persistence(old_state)
          self.update_attributes(machine.previous_state_column.to_sym => old_state) if machine.previous_state_column
        end

        def ensure_initial_state
          send("#{self.machine.state_column.to_s}=", self.current_state.name.to_s) if send(self.machine.state_column.to_s).blank?
        end
      end
    end
  end
end
