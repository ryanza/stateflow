require 'benchmark'
require 'active_record'
require 'stateflow'
require 'aasm'

# change this if sqlite is unavailable
dbconfig = {
  :adapter => 'sqlite3',
  :database => ':memory:'
}

ActiveRecord::Base.establish_connection(dbconfig)
ActiveRecord::Migration.verbose = false


class TestMigration < ActiveRecord::Migration
  STATE_MACHINES = ['stateflow', 'aasm']

  def self.up
    STATE_MACHINES.each do |name|
      create_table "#{name}_tests", :force => true do |t|
        t.column :state, :string
      end
    end
  end

  def self.down
    STATE_MACHINES.each do |name|
      drop_table "#{name}_tests"
    end
  end
end

Stateflow.persistence = :active_record

class StateflowTest < ActiveRecord::Base
  include Stateflow

  stateflow do
    initial :green

    state :green, :yellow, :red

    event :change_color do
      transitions :from => :green, :to => :yellow
      transitions :from => :yellow, :to => :red
      transitions :from => :red, :to => :green
    end
  end
end

class AasmTest < ActiveRecord::Base
  include AASM

  aasm_column :state # defaults to aasm_state

  aasm_initial_state :green

  aasm_state :green
  aasm_state :yellow
  aasm_state :red

  aasm_event :change_color do
    transitions :from => :green, :to => :yellow
    transitions :from => :yellow, :to => :red
    transitions :from => :red, :to => :green
  end
end

n = 1000
TestMigration.up

Benchmark.bm(7) do |x|
  x.report('stateflow') do
    n.times do
      stateflow = StateflowTest.new
      3.times { stateflow.change_color! }
    end
  end
  x.report('aasm') do
    n.times do
      aasm = AasmTest.new
      3.times { aasm.change_color! }
    end
  end
end

TestMigration.down
