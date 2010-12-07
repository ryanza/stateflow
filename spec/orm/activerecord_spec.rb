require 'spec_helper'
require 'active_record'

Stateflow.persistence = :active_record

# change this if sqlite is unavailable
dbconfig = {
  :adapter => 'sqlite3',
  :database => ':memory:'
}

ActiveRecord::Base.establish_connection(dbconfig)
ActiveRecord::Migration.verbose = false

class TestMigration < ActiveRecord::Migration
  def self.up
    create_table :robots, :force => true do |t|
      t.column :state, :string
      t.column :name, :string
    end
  end

  def self.down
    drop_table :robots
  end
end

class Robot < ActiveRecord::Base
  include Stateflow
  
  stateflow do
    initial :red

    state :red, :green

    event :change do
      transitions :from => :red, :to => :green
    end
  end
end

describe Stateflow::Persistence::ActiveRecord do
  before(:all) { TestMigration.up }
  after(:all) { TestMigration.down }
  after { Robot.delete_all }

  let(:robot) { Robot.new }

  it "should save to persistence with bang method" do
    @robot = robot
    @robot.state = "red"
    @robot.new_record?.should be_true

    @robot.change!

    @robot.new_record?.should be_false
    @robot.reload.state.should == "green"
  end

  it "should not save to persistence with no bang method" do
    @robot = robot
    @robot.state = "red"
    @robot.new_record?.should be_true

    @robot.change

    @robot.new_record?.should be_true
    @robot.state.should == "green"
  end

  it "Make sure stateflow saves the initial state if no state is set" do
    @robot = robot

    @robot.save
    @robot.reload

    @robot.state.should == "red"
  end

  it "should load state from persistence" do
    @robot = robot
    @robot.state = "green"
    @robot.name = "Bottie"
    @robot.save

    result = Robot.find_by_name("Bottie")
    result.should_not be_blank
    result.state.should == "green"
    result.current_state.name.should == :green
  end
end

