module Stateflow
  module Persistence
    module MongoMapper
      def self.install(base)
        ActiveSupport::Deprecation.silence do
          base.respond_to?(:before_validation_on_create) ? base.before_validation_on_create(:ensure_initial_state) : base.before_validation(:ensure_initial_state, :on => :create)
          base.send :include, InstanceMethods
        end
      end
      
      module InstanceMethods
        def load_from_persistence
          self.send machine.state_column.to_sym
        end

        def save_to_persistence(new_state, options = {})
          self.send("#{machine.state_column}=".to_sym, new_state)
          self.save if options[:save]
        end
        
        def ensure_initial_state
          send("#{self.machine.state_column.to_s}=", self.current_state.name.to_s) if self.send(self.machine.state_column.to_s).blank?
        end
      end
    end
  end
end
