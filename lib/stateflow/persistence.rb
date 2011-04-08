module Stateflow
  module Persistence
    Dir[File.dirname(__FILE__) + '/persistence/*.rb'].each do |file|
      name = File.basename(file, File.extname(file))
      
      Stateflow.active_persistences << name.underscore.to_sym
      autoload name.camelize.to_sym, file
    end
  end
end