module Stateflow
  module Persistence
    def self.active
      persistences = Array.new
      
      Dir[File.dirname(__FILE__) + '/persistence/*.rb'].each do |file|
        persistences << File.basename(file, File.extname(file)).underscore.to_sym
      end
      
      persistences
    end
    
    def self.load!(base)
      begin
        base.send :include, "Stateflow::Persistence::#{Stateflow.persistence.to_s.camelize}".constantize
      rescue NameError
        puts "[Stateflow] The ORM you are using does not have a Persistence layer. Defaulting to ActiveRecord."
        puts "[Stateflow] You can overwrite the persistence with Stateflow.persistence = :new_persistence_layer"

        Stateflow.persistence = :active_record 
        base.send :include, "Stateflow::Persistence::ActiveRecord".constantize
      end
    end
    
    Stateflow::Persistence.active.each do |p|
      autoload p.to_s.camelize.to_sym, "stateflow/persistence/#{p.to_s}"
    end
  end
end