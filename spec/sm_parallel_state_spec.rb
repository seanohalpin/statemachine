require File.dirname(__FILE__) + '/spec_helper'

describe "Nested parallel" do
  before(:each) do
    @out_out_order = false

    @sm = Statemachine.build do
      trans :start,:go,:p
      state :maintenance
      parallel :p do
        statemachine :s1 do
          superstate :operative do
            trans :locked, :coin, :unlocked, Proc.new { @locked = false }
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

   @sm.context = self
  end

  it "supports entering a parallel state" do
    @sm.state.should eql :start
    @sm.go
    @sm.state.should eql :p
    @sm.states.should == [:locked,:on]
    @sm.coin
    @sm.state.should eql :p
    @sm.states.should == [:unlocked,:on]
    @sm.toggle
    @sm.state.should eql :p
    @sm.states.should == [:unlocked,:off]
  end

  it "supports leaving a parallel state" do
    @sm.states.should == [:start]
    @sm.go
    @sm.states.should == [:locked,:on]
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
end
