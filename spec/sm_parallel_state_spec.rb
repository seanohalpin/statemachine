require File.dirname(__FILE__) + '/spec_helper'
require "noodle"

describe "Nested parallel" do
  before(:each) do
    @out_out_order = false
    @locked = true
    @noodle = Noodle.new

    @sm = Statemachine.build do
      trans :start,:go,:p
      state :maintenance
      parallel :p do
        statemachine :s1 do
          superstate :operative do
            trans :locked, :coin, :unlocked, Proc.new {  @cooked = true }
            trans :unlocked, :coin, :locked
            event :maintain, :maintenance, Proc.new { @out_of_order = true }
          end
        end
        statemachine :s2 do
          superstate :onoff do
            trans :on, :toggle, :off
            trans :off, :toggle, :on
          end
        end
      end
    end

    @sm.context = @noodle
  end
# @TODO add tests that set a certain state that is part of a parallel state machine
  # to check if
  # the other sub statemachine is set to the initial state
  # the other sub state machines states doe not change if already in this parallel state machine
  it "supports entering a parallel state" do
    @sm.state.should eql :start
    @sm.go
    @sm.state.should eql :p
    @sm.states_id.should == [:locked,:on]
    @sm.coin
    @sm.state.should eql :p
    @sm.states_id.should == [:unlocked,:on]
    @sm.toggle
    @sm.state.should eql :p
    @sm.states_id.should == [:unlocked,:off]
  end

  it "supports leaving a parallel state" do
    @sm.states_id.should == [:start]
    @sm.go
    @sm.states_id.should == [:locked,:on]
    @sm.maintain
    @sm.state.should == :maintenance

  end

  it "support testing with 'in' condition for  superstates " do
    @sm.go
    @sm.process_event(:coin)
    @sm.In(:unlocked).should == true
  end

  it "support testing with 'in' condition for parallel  superstates " do
    @sm.go
    @sm.coin
    @sm.In(:onoff).should == true
    @sm.In(:operative).should == true
    @sm.In(:on).should == true

#    @sm.is_in_state?(:second).should == true

    @sm.maintain # TODO not working
    @sm.In(:maintenance).should == true
  end

  it "supports process_event for parallel states" do
    @sm.go
    @sm.process_event(:coin)
    @sm.In(:onoff).should == true
    @sm.In(:operative).should == true
    @sm.In(:on).should == true
  end

  it "supports calling transition actions inside parallel state changes" do
    @noodle.cooked.should equal(false)
    @sm.go
    @sm.process_event(:coin)
    @noodle.cooked.should equal(true)
  end

  it "supports calling transition actions inside parallel state changes from instant context set by process_event" do
    @noodle2 = Noodle.new
    @noodle2.cooked.should equal(false)
    @sm.go
    @sm.context = @noodle2
    @sm.process_event(:coin)
    @noodle2.cooked.should equal(true)
  end

  it "should support state recovery" do
    @sm.states=[:locked,:off]
    @sm.toggle
    puts @sm.abstract_states
  end

  it "should support parallel states inside superstates" do
    @sm = Statemachine.build do
      trans :start,:go,:s
      state :maintenance
      superstate :s do
        parallel :p do
          statemachine :s1 do
            superstate :operative do
              trans :locked, :coin, :unlocked, Proc.new {  @cooked = true }, Proc.new{ In(:on) }
              trans :unlocked, :coin, :locked
              event :maintain, :maintenance, Proc.new { @out_of_order = true }
            end
          end
          statemachine :s2 do
            superstate :onoff do
              trans :on, :toggle, :off
              trans :off, :toggle, :on
            end
          end
        end
      end
    end

    @sm.go
    @sm.states_id.should == [:locked,:on]
    @sm.toggle
    @sm.states_id.should == [:locked,:off]
    @sm.coin
  end

  it "should support direct transitions into an atomic state of a parallel state set" do
    @sm = Statemachine.build do
      trans :start,:go, :unlocked
      state :maintenance
      superstate :s do
        parallel :p do
          statemachine :s1 do
            superstate :operative do
              trans :locked, :coin, :unlocked, Proc.new {  @cooked = true }
              trans :unlocked, :coin, :locked
              event :maintain, :maintenance, Proc.new { @out_of_order = true }
            end
          end
          statemachine :s2 do
            superstate :onoff do
              trans :on, :toggle, :off
              trans :off, :toggle, :on
            end
          end
        end
      end
    end

    @sm.go
    @sm.state.should == :p
    @sm.states_id.should == [:unlocked,:on]
    @sm.maintain
    @sm.state.should == :maintenance
    @sm.states_id.should == [:maintenance]
  end

  it "should support leaving a parallel state by an event from a super state of the parallel state" do
    #pending ("parallel states have problems with late defined events ")
    @sm = Statemachine.build do
      trans :start,:go, :unlocked
      state :maintenance
      superstate :test do
        superstate :s do
          event :m, :maintenance
          parallel :p do
            statemachine :s1 do
                trans :locked, :coin, :unlocked, Proc.new {  @cooked = true }
                trans :unlocked, :coin, :locked
            end
            statemachine :s2 do
              superstate :onoff do
                trans :on, :toggle, :off
                trans :off, :toggle, :on
              end
            end
          end
        end
        event :repair, :maintenance # this one does not work, event has to be defined directly after superstate definition!
      end
    end

    @sm.go
    @sm.state.should eql :p
    @sm.states_id.should == [:unlocked,:on]
    @sm.toggle
    @sm.repair
    @sm.state.should eql :maintenance
    @sm.states_id.should == [:maintenance]
  end

  it "should fail for undefined events if actual state is inside a parallel state" do
    @sm.go
    lambda {@sm.unknown}.should raise_error
  end


it "should support entering a nested parallel states" do
    #pending ("parallel states have problems with late defined events ")
    @sm = Statemachine.build do
      trans :start,:go, :unlocked
      state :maintenance
      superstate :test do
        superstate :s do
          event :m, :maintenance
          parallel :p do
            statemachine :s1 do
                trans :locked, :coin, :unlocked, Proc.new {  @cooked = true }
                trans :unlocked, :coin, :locked
            end
            statemachine :s2 do
              #superstate :r2 do
                parallel :p2 do
                  statemachine :s21 do
                    superstate :onoff do
                      trans :on, :toggle, :off
                      trans :off, :toggle, :on
                    end
                  end
                  statemachine :s22 do
                    superstate :onoff2 do
                      trans :on2, :toggle2, :off2
                      trans :off2, :toggle2, :on2
                      end
                  end
                end
              #end
            end
          end
        end
        event :repair, :maintenance # this one does not work, event has to be defined directly after superstate definition!
      end
    end

    @sm.go
    @sm.state.should eql :p
    @sm.states_id.should == [:unlocked,:on,:on2]
    @sm.toggle2
    @sm.states_id.should == [:unlocked,:on,:off2]
    @sm.repair
    @sm.state.should eql :maintenance
    @sm.states_id.should == [:maintenance]
  end


end
