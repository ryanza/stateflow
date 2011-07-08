require 'spec_helper'
require 'mongoid'

Stateflow.persistence = :mongoid

connection = Mongo::Connection.new
Mongoid.database = connection.db("stateflow_test")

class MongoRobot
  include Mongoid::Document
  include Stateflow

  field :state
  field :name

  stateflow do
    initial :red

    state :red, :green

    event :change do
      transitions :from => :red, :to => :green
    end
  end
end

describe Stateflow::Persistence::Mongoid do
  after { MongoRobot.collection.drop }
  
  let(:robot) { MongoRobot.new }
  
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
    @robot = robot

    @robot.save
    @robot.reload

    @robot.state.should == "red"
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
      MongoRobot.should respond_to(:red)
      MongoRobot.should respond_to(:green)
    end

    it "should behave like Mongoid scopes" do
      2.times { MongoRobot.create(:state => "red") }
      3.times { MongoRobot.create(:state => "green") }
      MongoRobot.red.count.should == 2
      MongoRobot.green.count.should == 3
    end
  end
end

