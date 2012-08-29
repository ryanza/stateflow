# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{stateflow}
  s.version = "0.5.0.beta"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ryan Oberholzer"]
  s.date = %q{2011-04-08}
  s.description = %q{State machine that allows dynamic transitions for business workflows}
  s.email = %q{ryan@platform45.com}
  s.extra_rdoc_files = ["CHANGELOG.rdoc", "README.rdoc", "lib/stateflow.rb", "lib/stateflow/event.rb", "lib/stateflow/exception.rb", "lib/stateflow/machine.rb", "lib/stateflow/persistence.rb", "lib/stateflow/persistence/active_record.rb", "lib/stateflow/persistence/mongo_mapper.rb", "lib/stateflow/persistence/mongoid.rb", "lib/stateflow/persistence/none.rb", "lib/stateflow/railtie.rb", "lib/stateflow/state.rb", "lib/stateflow/transition.rb"]
  s.files = ["CHANGELOG.rdoc", "Gemfile", "Gemfile.lock", "LICENCE", "Manifest", "README.rdoc", "Rakefile", "benchmark/compare_state_machines.rb", "examples/robot.rb", "examples/test.rb", "init.rb", "lib/stateflow.rb", "lib/stateflow/event.rb", "lib/stateflow/exception.rb", "lib/stateflow/machine.rb", "lib/stateflow/persistence.rb", "lib/stateflow/persistence/active_record.rb", "lib/stateflow/persistence/mongo_mapper.rb", "lib/stateflow/persistence/mongoid.rb", "lib/stateflow/persistence/none.rb", "lib/stateflow/railtie.rb", "lib/stateflow/state.rb", "lib/stateflow/transition.rb", "spec/orm/activerecord_spec.rb", "spec/orm/mongoid_spec.rb", "spec/spec_helper.rb", "spec/stateflow_spec.rb", "stateflow.gemspec"]
  s.homepage = %q{http://github.com/ryanza/stateflow}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Stateflow", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{stateflow}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{State machine that allows dynamic transitions for business workflows}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 3.2"])
      s.add_development_dependency(%q<rspec>, [">= 2.0.0"])
      s.add_development_dependency(%q<activerecord>, [">= 3.2"])
      s.add_development_dependency(%q<mongoid>, [">= 2.0.0.beta.20"])
      s.add_development_dependency(%q<sqlite3-ruby>, [">= 0"])
      s.add_development_dependency(%q<echoe>, [">= 4.6.3"])
    else
      s.add_dependency(%q<activesupport>, [">= 3.2"])
      s.add_dependency(%q<rspec>, [">= 2.0.0"])
      s.add_dependency(%q<activerecord>, [">= 3.2"])
      s.add_dependency(%q<mongoid>, [">= 2.0.0.beta.20"])
      s.add_dependency(%q<sqlite3-ruby>, [">= 0"])
      s.add_dependency(%q<echoe>, [">= 4.6.3"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 3.2"])
    s.add_dependency(%q<rspec>, [">= 2.0.0"])
    s.add_dependency(%q<activerecord>, [">= 3.2"])
    s.add_dependency(%q<mongoid>, [">= 2.0.0.beta.20"])
    s.add_dependency(%q<sqlite3-ruby>, [">= 0"])
    s.add_dependency(%q<echoe>, [">= 4.6.3"])
  end
end
