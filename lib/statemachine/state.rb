module Statemachine

  class State #:nodoc:

    attr_reader :id, :statemachine, :superstate
    attr_accessor :entry_action, :exit_action
    attr_writer :default_transition

    def initialize(id, superstate, state_machine)
      @id = id
      @superstate = superstate
      @statemachine = state_machine
      @transitions = {}
    end

    def add(transition)
      @transitions[transition.event] = transition
    end

    def transitions
      return @superstate ? @transitions.merge(@superstate.transitions) : @transitions
    end

    def non_default_transition_for(event)
      transition = @transitions[event]
      transition = @superstate.non_default_transition_for(event) if @superstate and not transition
      return transition
    end

    def default_transition
      return @default_transition if @default_transition
      return @superstate.default_transition if @superstate
      return nil
    end

    def transition_for(event)
      transition = non_default_transition_for(event)
      transition = default_transition if not transition
      return transition
    end

    def exit(args)
      messenger = self.statemachine.messenger
      message_queue = self.statemachine.message_queue
      @statemachine.trace("\texiting #{self}")
      @statemachine.invoke_action(@exit_action, args, "exit action for #{self}", messenger, message_queue) if @exit_action
      @superstate.substate_exiting(self) if @superstate
    end

    def enter(args=[])
      messenger = self.statemachine.messenger
      message_queue = self.statemachine.message_queue
      @statemachine.trace("\tentering #{self}")
      @statemachine.invoke_action(@entry_action, args, "entry action for #{self}", messenger, message_queue) if @entry_action
    end

    def activate
      @statemachine.state = self
    end

    def concrete?
      return true
    end

    def resolve_startstate
      return self
    end

    def reset

    end

    def to_s
      return "'#{id}' state"
    end

  end

end