require 'spec_helper'

class Robot
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

class Car 
  include Stateflow
  
  stateflow do
    initial :parked
    
    state :parked do
      enter do
        "Entering parked"
      end
      
      exit do
        "Exiting parked"
      end
    end
    
    state :driving do
      enter do
        "Entering parked"
      end
    end
    
    event :drive do
      transitions :from => :parked, :to => :driving
    end
    
    event :park do
      transitions :from => :driving, :to => :parked
    end
  end
end

class Bob
  include Stateflow
  
  stateflow do
    state :yellow, :red, :purple
    
    event :change_hair_color do
      transitions :from => :purple, :to => :yellow
      transitions :from => :yellow, :to => :red
      transitions :from => :red, :to => :purple
    end
  end
end

class Dater
  include Stateflow
  
  stateflow do
    state :single, :dating, :married
    
    event :take_out do
      transitions :from => :single, :to => :dating
    end
    
    event :gift do
      transitions :from => :dating, :to => [:single, :married], :decide => :girls_mood?
    end
    
    event :blank_decision do
      transitions :from => :single, :to => [:single, :married], :decide => :girls_mood?
    end
    
    event :fail do
      transitions :from => :dating, :to => [:single, :married]
    end
  end
  
  def girls_mood?
  end
end

class Priority
  include Stateflow
  
  stateflow do
    initial :medium
    state :low, :medium, :high
    
    event :low do
      transitions :from => any, :to => :low
    end
    
    event :medium do 
      transitions :from => any, :to => :medium
    end    
    
    event :high do 
      transitions :from => any, :to => :high
    end
  end
end

describe Stateflow do
  describe "class methods" do
    it "should respond to stateflow block to setup the intial stateflow" do
      Robot.should respond_to(:stateflow)
    end
    
    it "should respond to the machine attr accessor" do
      Robot.should respond_to(:machine)
    end
  end
  
  describe "instance methods" do
    before(:each) do
      @r = Robot.new
    end
    
    it "should respond to current state" do
      @r.should respond_to(:current_state)
    end
    
    it "should respond to the current state setter" do
      @r.should respond_to(:current_state=)
    end
    
    it "should respond to the current machine" do
      @r.should respond_to(:machine)
    end
    
    it "should respond to load from persistence" do
      @r.should respond_to(:load_from_persistence)
    end
    
    it "should respond to save to persistence" do
      @r.should respond_to(:save_to_persistence)
    end
  end
  
  describe "initial state" do
    it "should set the initial state" do
      robot = Robot.new
      robot.current_state.name.should == :green
    end
    
    it "should return true for green?" do
      robot = Robot.new
      robot.green?.should be_true
    end
    
    it "should return false for yellow?" do
      robot = Robot.new
      robot.yellow?.should be_false
    end
    
    it "should return false for red?" do
      robot = Robot.new
      robot.red?.should be_false
    end
    
    it "should set the initial state to the first state set" do
      bob = Bob.new
      bob.current_state.name.should == :yellow
      bob.yellow?.should be_true
    end
  end
  
  it "robot class should contain red, yellow and green states" do
    robot = Robot.new
    robot.machine.states.keys.should include(:red, :yellow, :green)
  end
  
  describe "firing events" do
    it "should call the fire method on event" do
      robot = Robot.new
      robot.machine.events[:change_color].should_receive(:fire)
      robot.change_color!
    end
    
    it "should call the fire_event method" do
      robot = Robot.new
      robot.should_receive(:fire_event).with(:change_color)
      robot.change_color!
    end
    
    it "should raise an exception if the event does not exist" do
      robot = Robot.new
      lambda { robot.send(:fire_event, :fake) }.should raise_error(Stateflow::NoEventFound)
    end
    
    it "should fire the event" do
      robot = Robot.new
      robot.should_receive(:fire_event).with(:change_color)
      robot.change_color!
    end
    
    it "should update the event" do
      robot = Robot.new
      robot.current_state.name.should == :green
      robot.change_color!
      robot.current_state.name.should == :yellow
    end
    
    describe "before filters" do
      before(:each) do
        @car = Car.new
      end
      
      it "should call the exit state before filter on the exiting old state" do
        @car.machine.states[:parked].should_receive(:execute_action).with(:exit, @car)
        @car.drive!
      end
      
      it "should call the enter state before filter on the entering new state" do
        @car.machine.states[:driving].should_receive(:execute_action).with(:enter, @car)
        @car.drive!
      end
    end
  end
  
  describe "persistence" do 
    it "should attempt to persist the new state and the name should be a string" do
      robot = Robot.new
      robot.should_receive(:save_to_persistence).with("yellow")
      robot.change_color!
    end
    
    it "should attempt to read the initial state from the persistence" do
      robot = Robot.new
      
      def robot.load_from_persistence
        :red
      end
      
      robot.current_state.name.should == :red
    end
  end
  
  describe "dynamic to transitions" do
    it "should raise an error without any decide argument" do
      date = Dater.new
      
      def date.load_from_persistence
        :dating
      end
      
      lambda { date.fail! }.should raise_error(Stateflow::IncorrectTransition)
    end
    
    it "should raise an error if the decision method does not return a valid state" do
      date = Dater.new
      
      def date.girls_mood?
        :lol
      end
      
      lambda { date.blank_decision! }.should raise_error(Stateflow::NoStateFound, "Decision did not return a state that was set in the 'to' argument")
    end
    
    it "should raise an error if the decision method returns blank/nil" do
      date = Dater.new

      def date.girls_mood?
      end

      lambda { date.blank_decision! }.should raise_error(Stateflow::NoStateFound, "Decision did not return a state that was set in the 'to' argument")
    end
    
    it "should calculate the decide block or method and transition to the correct state" do
      date = Dater.new
      
      def date.load_from_persistence
        :dating
      end
      
      date.current_state.name.should == :dating
      
      def date.girls_mood?
        :single
      end
      
      date.gift!
      
      date.current_state.name.should == :single
    end
  end
  
  describe "transitions from any" do 
    it "should properly change state" do
      priority = Priority.new
      priority.low!
      priority.should be_low
      priority.medium!
      priority.should be_medium
      priority.high!
      priority.should be_high
    end
  end
end

