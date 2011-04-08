module Stateflow
  class Railtie < Rails::Railtie
    def default_orm
      generators = config.respond_to?(:app_generators) ? :app_generators : :generators
      config.send(generators).options[:rails][:orm]
    end
    
    initializer "stateflow.set_persistence" do
      Stateflow.persistence = default_orm if Stateflow.persistence.blank?
    end
  end
end