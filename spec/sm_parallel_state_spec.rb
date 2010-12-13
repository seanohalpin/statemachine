require File.dirname(__FILE__) + '/spec_helper'
require "noodle"

describe "Turn Stile" do
  include TurnstileStatemachine
  
  before(:each) do
    create_turnstile
    
    @out_out_order = false
    
    @sm = Statemachine.parallel_build do
      statemachine :first do 
        superstate :operative do
          trans :locked, :coin, :unlocked, Proc.new { @locked = false }
          trans :unlocked, :pass, :locked, Proc.new { @locked = true }
          trans :locked, :pass, :locked, Proc.new { @alarm_status = true }
          trans :unlocked, :coin, :locked, Proc.new { @thankyou_status = true }
          event :maintain, :maintenance, Proc.new { @out_of_order = true }
        end
        trans :maintenance, :operate, :operative, Proc.new { @out_of_order = false }
        startstate :locked 
      end
      statemachine :second do 
        superstate :onoff do
          trans :on, :toggle, :off
          trans :off, :toggle, :on
        end
      end
    end
    @sm.context = self

  end

  it "start with two initial states" do
    @sm.states.should == [:locked,:on]  
  end

  it "support transitions for both parallel superstates" do
    @sm.process_event(:coin)
    @sm.process_event(:toggle)
    @sm.states.should == [:unlocked,:off]
  end

  it "support testing with 'in' condition for primitive states " do
      @sm.process_event(:coin)
      @sm.is_in_state?(:unlocked).should == true
  end

  it "support testing with 'in' condition for  superstates " do
      @sm.process_event(:coin)
      @sm.is_in_state?(:operative).should == true
  end

  it "support testing with 'in' condition for parallel  superstates " do
    @sm.process_event(:coin)
    @sm.is_in_state?(:onoff).should == true
    @sm.is_in_state?(:operative).should == true
    
    # @sm.is_in_state?(:second).should == true ;; is not supported!!

    @sm.process_event(:maintain)
    @sm.is_in_state?(:operative).should == false
  end
end

describe "Action Invokation" do

  before(:each) do
    @noodle = Noodle.new
  end
  
  it "Symbol actions" do
    sm = Statemachine.parallel_build do 
      statemachine :one do
        trans :cold, :fire, :hot, :cook
      end
      statemachine :two do
        trans :hot, :mold, :changed, :transform
      end
    end
    sm.context = @noodle

    @noodle.cooked.should equal(false)    
    sm.process_event(:fire)
    @noodle.cooked.should equal(true)

    sm.process_event(:mold,"fettucini")
    @noodle.shape.should eql("fettucini")

  end


end
