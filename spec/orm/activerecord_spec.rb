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
    create_table :active_record_robots, :force => true do |t|
      t.column :state, :string
      t.column :name, :string
    end
  end

  def self.down
    drop_table :active_record_robots
  end
end

class ActiveRecordRobot < ActiveRecord::Base
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
  after { ActiveRecordRobot.delete_all }

  let(:robot) { ActiveRecordRobot.new }

  describe "includes" do
    it "should include current_state" do
      robot.respond_to?(:current_state).should be_true
    end

    it "should include current_state=" do
      robot.respond_to?(:set_current_state).should be_true
    end

    it "should include save_to_persistence" do
      robot.respond_to?(:save_to_persistence).should be_true
    end

    it "should include load_from_persistence" do
      robot.respond_to?(:load_from_persistence).should be_true
    end
  end

  describe "bang method" do
    before do
      @robot = robot
      @robot.state = "red"
    end

    it "should call the set_current_state with save being true" do
      @robot.should_receive(:set_current_state).with(@robot.machine.states[:green], {:save=>true})
      @robot.change!
    end

    it "should save the record" do
      @robot.new_record?.should be_true
      @robot.change!
      @robot.new_record?.should be_false
      @robot.reload.state.should == "green"
    end
  end

    describe "non bang method" do
    before do
      @robot = robot
      @robot.state = "red"
    end

    it "should call the set_current_state with save being false" do
      @robot.should_receive(:set_current_state).with(@robot.machine.states[:green], {:save=>false})
      @robot.change
    end

    it "should not save the record" do
      @robot.new_record?.should be_true
      @robot.change
      @robot.new_record?.should be_true
      @robot.state.should == "green"
    end
  end

  it "Make sure stateflow saves the initial state if no state is set" do
    @robot3 = robot

    @robot3.save
    @robot3.reload

    @robot3.state.should == "red"
  end

  describe "load from persistence" do
    before do
      @robot = robot
      @robot.state = "green"
      @robot.name = "Bottie"
      @robot.save
    end

    it "should call the load_from_persistence method" do
     @robot.reload
     @robot.should_receive(:load_from_persistence)

     @robot.current_state
    end
  end
end

