require 'spec_helper'

describe "Turn Stile" do
  include TurnstileStatemachine
  
  before(:each) do
    create_turnstile
    
    @out_out_order = false
    
    @sm = Statemachine.build do 
      superstate :operative do
        trans :locked, :coin, :unlocked, Proc.new { @locked = false;true}
        trans :unlocked, :pass, :locked, Proc.new { @locked = true ;true}
        trans :locked, :pass, :locked, Proc.new { @alarm_status = true ;true}
        trans :unlocked, :coin, :locked, Proc.new { @thankyou_status = true ;true}
        event :maintain, :maintenance, Proc.new { @out_of_order = true ;true}
      end
      trans :maintenance, :operate, :operative, Proc.new { @out_of_order = false;true } 
      startstate :locked
    end
    @sm.context = self
  end

  it "substates respond to superstate transitions" do
    @sm.process_event(:maintain)
    @sm.state.should equal(:maintenance)
    @locked.should equal(true)
    @out_of_order.should equal(true)
  end

  it "after transitions, substates respond to superstate transitions" do
    @sm.coin
    @sm.maintain
    @sm.state.should equal(:maintenance)
    @locked.should equal(false)
    @out_of_order.should equal(true)
  end

  it "states could be redefined as superstates" do
    @sm = Statemachine.build @sm do
      superstate :unlocked do
        trans :u1, :u, :u2
        trans :u2, :e, :maintenance
      end
    end   

    @sm.coin
    @sm.state.should equal(:u1)
    @sm.u
    @sm.state.should equal(:u2)
    @sm.coin
    @sm.state.should equal(:locked)
  end
end
