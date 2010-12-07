require 'spec_helper'
require 'mongoid'

Stateflow.persistence = :mongoid

connection = Mongo::Connection.new
Mongoid.database = connection.db("stateflow_test")

class Robot
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

describe Stateflow::Persistence::ActiveRecord do
  after { Robot.collection.drop }
  
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

    result = Robot.where(:name => "Bottie").first
    result.should_not be_blank
    result.state.should == "green"
    result.current_state.name.should == :green
  end
end

