module Stateflow
  module Persistence
    def self.set(base)
      case Stateflow.persistence
        when :mongo_mapper
          Stateflow::Persistence::MongoMapper.install(base)
        when :active_record
          Stateflow::Persistence::ActiveRecord.install(base)
        when :mongoid
          Stateflow::Persistence::Mongoid.install(base)
        when :none
          Stateflow::Persistence::None.install(base)
      end
    end
    
    autoload :MongoMapper, 'stateflow/persistence/mongo_mapper'
    autoload :ActiveRecord, 'stateflow/persistence/active_record'
    autoload :Mongoid, 'stateflow/persistence/mongoid'
    autoload :None, 'stateflow/persistence/none'
  end
end