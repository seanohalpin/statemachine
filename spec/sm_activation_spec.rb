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
        @called = []
        @state = []
        @abstract_states = []
        @atomic_states =[]

      end
      def activate(state,abstract_states, atomic_states)
        @called << true
        @state <<  state
        @abstract_states << abstract_states
        @atomic_states <<  atomic_states
        puts "activate #{@state.last} #{@abstract_states.last} #{@atomic_states.last}"
      end
    end

    @callback = ActivationCallback.new
  end
  
  it "should fire on successful state change" do
    create_switch
    @sm.activation=@callback.method(:activate)
    @callback.called.length.should == 0
    @sm.toggle
    @callback.called.length.should == 1
  end

  it "should deliver new active state on state change" do
    create_switch
    @sm.activation=@callback.method(:activate)
    @sm.toggle
    @callback.state.last.should == :on
    @callback.atomic_states.last.should == [:on]
    @callback.abstract_states.last.should == [:root]
    @sm.toggle
    @callback.state.last.should == :off
  end

  it "should deliver new active state on state change of parallel state machine" do
    create_parallel

    @sm.activation=@callback.method(:activate)
    @sm.go
    @callback.called.length.should == 2
    @callback.state.last.should == :on
    @callback.abstract_states.last.should.eql? [:operative, :root, :onoff]
    @callback.atomic_states.last.should == [:locked, :on]
    @sm.toggle
    @callback.state.last.should == :off
    @callback.abstract_states.last.should.eql? [:onoff,:operative,:root]
    @callback.atomic_states.last.should.eql? [:off,:locked]

  end

  it "activation works for on_entry ticks as well" do
    create_tick
    @sm.activation=@callback.method(:activate)
    @sm.toggle
    @callback.called.length.should == 2
    @callback.state.last.should == :off
    @callback.state.first.should == :on
    @callback.atomic_states.last.should == [:off]
    @callback.atomic_states.first.should == [:on]
    @callback.abstract_states.last.should == [:root]
  end

end
