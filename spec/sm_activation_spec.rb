require File.dirname(__FILE__) + '/spec_helper'

describe "State Activation Callback" do
  include SwitchStatemachine
  include ParallelStatemachine

  before(:each) do
    class ActivationCallback
      attr_reader :called
      attr_reader :state
      attr_reader :abstract_states
      attr_reader :atomic_states

      def initialize
        @called = false
      end
      def activate(state,abstract_states, atomic_states)
        @called = true
        @state = state
        @abstract_states = abstract_states
        @atomic_states = atomic_states
        puts "activate #{state} #{abstract_states} #{atomic_states}"
      end
    end

    @callback = ActivationCallback.new
  end
  
  it "should fire on successful state change" do
    create_switch
    @sm.activation=@callback.method(:activate)
    @callback.called.should == false
    @sm.toggle
    @callback.called.should == true
  end

  it "should deliver new active state on state change" do
    create_switch
    @sm.activation=@callback.method(:activate)
    @sm.toggle
    @callback.state.should == :on
    @callback.atomic_states.should == [:on]
    @callback.abstract_states.should == [:root]
    @sm.toggle
    @callback.state.should == :off
  end

  it "should deliver new active state on state change of parallel state machine" do
    create_parallel

    @sm.activation=@callback.method(:activate)
    @sm.go
    @callback.called.should == true
    @callback.state.should == :on
    @callback.abstract_states.should.eql? [:operative, :root, :onoff]
    @callback.atomic_states.should == [:locked, :on]
    @sm.toggle
    @callback.state.should == :off
    @callback.abstract_states.should.eql? [:onoff,:operative,:root]
    @callback.atomic_states.should.eql? [:off,:locked]

  end

end
