module Statemachine

  class State #:nodoc:

    attr_reader :statemachine
    attr_accessor :id, :entry_action, :exit_action, :superstate
    attr_writer :default_transition

    def initialize(id, superstate, state_machine)
      @id = id
      @superstate = superstate
      @statemachine = state_machine
      @transitions = {}
      @spontaneous_transitions = []
    end

    def add(transition)
      if transition.event == nil
        @spontaneous_transitions.push(transition)
      else
        @transitions[transition.event] = transition
      end
    end

    def transitions
      return @superstate ? @transitions.merge(@superstate.transitions) : @transitions
    end

    def non_default_transition_for(event,check_superstates = true)
      transition = @transitions[event]
      if check_superstates and @superstate
        transition = @superstate.non_default_transition_for(event) if @superstate and @superstate.is_parallel == false and not transition
      end
      return transition
    end

    def default_transition
      return @default_transition if @default_transition
      return @superstate.default_transition if @superstate
      return nil
    end

    def spontaneous_transition
      @spontaneous_transitions.each do |s|
         return s if s.cond == true
         if s.cond
          return s if @statemachine.invoke_action(s.cond, [], "condition from #{@state} invoked by '#{nil}' event", nil, nil)
         end
      end
      return nil
    end

    def transition_for(event,check_superstate=true)
      transition = non_default_transition_for(event,check_superstate)
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
      # if (@statemachine.is_parallel)
      # @statemachine.activation.call(self.id,@statemachine.is_parallel.abstract_states,@statemachine.is_parallel.statemachine.states_id) if @statemachine.activation
      #else
      #@statemachine.activation.call(self.id,self.abstract_states,@statemachine.states_id) if @statemachine.activation # and  not @statemachine.is_parallel
      # end
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

    def has_superstate(id)
      return false if not @superstate
      return true if @superstate.id == id
      return @superstate.has_superstate(id)
    end

    def abstract_states
      return [] if not @superstate
      return @superstate.abstract_states #if not @superstate.is_parallel
      []
    end

    def is_parallel
      false
    end
  end

end
