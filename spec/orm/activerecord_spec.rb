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

    create_table :active_record_protected_robots, :force => true do |t|
      t.column :state, :string
      t.column :name, :string
    end
    
    create_table :active_record_no_scope_robots, :force => true do |t|
      t.column :state, :string
      t.column :name, :string
    end
  end

  def self.down
    drop_table :active_record_robots
    drop_table :active_record_protected_robots
    drop_table :active_record_no_scope_robots
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

class ActiveRecordProtectedRobot < ActiveRecord::Base
  include Stateflow
  
  attr_protected :state

  stateflow do
    initial :red

    state :red, :green

    event :change do
      transitions :from => :red, :to => :green
    end
  end
end

class ActiveRecordNoScopeRobot < ActiveRecord::Base
  include Stateflow
  
  attr_protected :state

  stateflow do
    create_scopes false
    initial :red

    state :red, :green

    event :change do
      transitions :from => :red, :to => :green
    end
  end
end

class ActiveRecordStateColumnSetRobot < ActiveRecord::Base
  include Stateflow
  
  stateflow do
    state_column :status
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
  after { ActiveRecordRobot.delete_all; ActiveRecordProtectedRobot.delete_all }

  let(:robot) { ActiveRecordRobot.new }
  let(:protected_robot) { ActiveRecordProtectedRobot.new }

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

    it "should call the setter method for the state column" do
      @robot.should_receive(:state=).with("green")
      @robot.change!
    end

    it "should call save after setting the state column" do
      @robot.should_receive(:save)
      @robot.change!
    end

    it "should save the record" do
      @robot.new_record?.should be_true
      @robot.change!
      @robot.new_record?.should be_false
      @robot.reload.state.should == "green"
    end

    it "should save the protected method" do
      @protected_robot = protected_robot
      @protected_robot.new_record?.should be_true
      @protected_robot.change!
      @protected_robot.new_record?.should be_false
      @protected_robot.reload.state.should == "green"
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

    it "should call the setter method for the state column" do
      @robot.should_receive(:state=).with("green")
      @robot.change
    end

    it "should call save after setting the state column" do
      @robot.should_not_receive(:save)
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
  
  describe "scopes" do
    it "should be added for each state" do
      ActiveRecordRobot.should respond_to(:red)
      ActiveRecordRobot.should respond_to(:green)
    end
    it "should be added for each state when the state column is not 'state'" do
      ActiveRecordStateColumnSetRobot.should respond_to(:red)
      ActiveRecordStateColumnSetRobot.should respond_to(:green)    
    end
    
    it "should not be added for each state" do
      ActiveRecordNoScopeRobot.should_not respond_to(:red)
      ActiveRecordNoScopeRobot.should_not respond_to(:green)
    end

    it "should behave like Mongoid scopes" do
      2.times { ActiveRecordRobot.create(:state => "red") }
      3.times { ActiveRecordRobot.create(:state => "green") }
      ActiveRecordRobot.red.count.should == 2
      ActiveRecordRobot.green.count.should == 3
    end
  end
end

