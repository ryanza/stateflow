module Stateflow
  module Persistence
    Dir[File.dirname(__FILE__) + '/persistence/*.rb'].each do |file| 
      autoload File.basename(file, File.extname(file)).camelize.to_sym, file
    end
  end
end