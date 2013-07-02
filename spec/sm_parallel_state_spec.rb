require 'spec_helper'
require "noodle"

describe "Parallel states" do
  before(:each) do
    @out_out_order = false
    @locked = true
    @noodle = Noodle.new

    @sm = Statemachine.build do
      trans :start,:go,:p
     # state :maintenance
      trans :maintenance,:go,:p
      trans :maintenance,:go2,:locked

      parallel :p do
        event :activate_exit, :maintain
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

  it "should call exit only once if exiting parallel state" do
    counter = 0
    @sm.get_state(:p).exit_action = Proc.new { counter += 1 }
    @sm.go
    @sm.activate_exit
    counter.should == 1
  end

  it "should call enter only once if entering parallel state" do
    counter = 0
    @sm.get_state(:p).entry_action = Proc.new { counter += 1 }
    @sm.go
    counter.should == 1
  end


# @TODO add tests that set a certain state that is part of a parallel state machine
# to check if
# the other sub statemachine is set to the initial state
# the other sub state machines states doe not change if already in this parallel state machine
  it "supports entering a parallel state" do
    @sm.state.should eql :start
    @sm.go
    @sm.abstract_states.should ==[:root,:p,  :operative, :onoff ]
    @sm.state.should eql :p
    @sm.states_id.should == [:locked,:on]
    @sm.coin
    @sm.state.should eql :p
    @sm.states_id.should == [:unlocked,:on]
    @sm.abstract_states.should ==[:root,:p,  :operative, :onoff ]
    @sm.toggle
    @sm.state.should eql :p
    @sm.states_id.should == [:unlocked,:off]
    @sm.abstract_states.should ==[:root,:p,  :operative, :onoff ]

  end

  it "supports leaving a parallel state" do
    @sm.states_id.should == [:start]
    @sm.go
    @sm.states_id.should == [:locked,:on]
    @sm.maintain
    @sm.state.should == :maintenance
    @sm.abstract_states.should ==[:root ]

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

  it "should support state recovery to initial states  upon entering the parallel super state  if without history state" do
    @sm.states=[:locked,:on]
    @sm.toggle
    @sm.states_id.should == [:locked,:off]
    @sm.maintain
    @sm.states_id.should == [:maintenance]
    @sm.go
    @sm.states_id.should == [:locked,:on]
  end


  it "should support state recovery to initial states upon direct entering a child of the parallel super state  if without history state" do
    @sm.states=[:locked,:on]
    @sm.toggle
    @sm.states_id.should == [:locked,:off]
    @sm.maintain
    @sm.states_id.should == [:maintenance]
    @sm.go2
    @sm.states_id.should == [:locked,:on]
  end

  it "should support parallel states inside superstates" do
    @sm = Statemachine.build do
      trans :start,:go,:s
      state :maintenance
      superstate :s do
        parallel :p do
          statemachine :s1 do
            superstate :operative do
              trans :locked, :coin, :unlocked, Proc.new {  @cooked = true }, "In(:on)"
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
    @sm.abstract_states.should ==[:s,:root,:p,  :operative, :onoff ]
    @sm.maintain
    @sm.state.should == :maintenance
    @sm.states_id.should == [:maintenance]
    @sm.abstract_states.should ==[:root]

  end

  it "should support leaving a parallel state by an event from a super state of the parallel state" do
    @sm = Statemachine.build do
      trans :start,:go, :unlocked
      state :maintenance
      superstate :test do
        superstate :s do
          event :m, :maintenance
          parallel :p do
            statemachine :s1 do
              superstate :s11 do
                trans :locked, :coin, :unlocked, Proc.new {  @cooked = true }
                trans :unlocked, :coin, :locked
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
        event :repair, :maintenance
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

  it "should support spontaneous initial transitions" do

    @sm = Statemachine.build do
      trans :start,:go,:p

      parallel :p do
        statemachine :s1 do
          superstate :operative do
            trans :locked, nil, :unlocked
            trans :unlocked, :coin, :locked
          end
        end
        statemachine :s2 do
          superstate :onoff do
            trans :on, nil, :off
            trans :off, :toggle, :on
          end
        end
      end

    end

    @sm.go
    @sm.state.should eql :p
    @sm.states_id.should == [:unlocked,:off]
  end

  describe "state flows" do
    before(:each) do
      @state_flow = []

      def activate(new_states,abstract_states, atomic_states)
        @state_flow << new_states
      end

    end
    it "should support spontaneous initial transitions triggered by direct transition into a parallel atomic state" do

      @sm = Statemachine.build do
        trans :start,:go,:on

        parallel :p do
          statemachine :s1 do
            superstate :operative do
              trans :locked, nil, :unlocked
              trans :unlocked, :coin, :locked
            end
          end
          statemachine :s2 do
            superstate :onoff do
              trans :on, nil, :off
              trans :off, :toggle, :on
            end
          end
        end
      end
      @sm.activation=self.method(:activate)
      @sm.go
      @sm.state.should eql :p
      @state_flow.should == [[:p, :operative, :onoff, :locked, :on],[:unlocked],[:off]]
      @sm.states_id.should == [:unlocked,:off]
    end

    it "should support spontaneous initial transitions triggered by direct transition into a parallel atomic state" do
      @sm = Statemachine.build do
        trans :start,:go,:a1

        superstate :s do
          trans :a1, nil, :a2
          trans :a2, nil, :locked

          parallel :p do
            statemachine :s1 do
              superstate :operative do
                trans :locked, nil, :unlocked
                trans :unlocked, :coin, :locked
              end
            end
            statemachine :s2 do
              superstate :onoff do
                trans :on, nil, :off
                trans :off, :toggle, :on
              end
            end
          end
        end
      end
      @sm.activation=self.method(:activate)
      @sm.go
      @sm.state.should eql :p
      @state_flow.should == [[:s, :a1], [:a2],[:p, :operative, :onoff, :locked, :on],[:unlocked],[:off] ]
      @sm.states_id.should == [:unlocked,:off]
    end
  end
end

describe "Nested parallel states" do
  before (:each) do
    @sm = Statemachine.build do
      trans :start,:go, :unlocked
      state :maintenance
      superstate :test do
        superstate :s do
          event :m, :maintenance
          parallel :p do
            statemachine :s1 do
              superstate :s11 do
                trans :locked, :coin, :unlocked, Proc.new {  @cooked = true }
                trans :unlocked, :coin, :locked
              end
            end
            statemachine :s2 do
              superstate :r2 do
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
              end
            end
          end
        end
        event :repair, :maintenance
      end
    end
  end

  it "should point to their own state machine" do
    @sm.go
    @sm.state.should eql :p

  end

  it "should support entering a nested parallel states" do
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

