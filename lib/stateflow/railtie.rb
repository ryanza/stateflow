module Stateflow
  class Railtie < Rails::Railtie
    def default_orm
      config.app_generators.options[:rails][:orm]
    end
    
    initializer "stateflow.set_persistence" do
      Stateflow.persistence = default_orm if Stateflow.persistence.blank? && Stateflow.active_persistences.include?(default_orm)
    end
  end
end