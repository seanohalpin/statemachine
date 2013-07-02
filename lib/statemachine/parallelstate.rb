module Statemachine

  class Parallelstate < Superstate

    attr_accessor :parallel_statemachines, :id, :entry_action, :exit_action
    attr_reader :startstate_ids

    def initialize(id, superstate, statemachine)
      super(id, superstate, statemachine)
      @parallel_statemachines=[]
      @startstate_ids=[]
      @transitions = []
      @spontaneous_transitions = []
    end

    def add(transition)
      if transition.event == nil
        @spontaneous_transitions.push(transition)
      else
        @transitions.push(transition)
      end
    end

    def context= c
      @parallel_statemachines.each do |s|
        s.context=c
      end
    end

    def activate(terminal_state = nil)
      @parallel_statemachines.each do |s|
        next if terminal_state and s.has_state(terminal_state)
        #     @statemachine.activation.call(s.state,self.abstract_states+s.abstract_states,s.state) if @statemachine.activation
      end

    end

    def add_statemachine(statemachine)
      statemachine.is_parallel=self
      @parallel_statemachines.push(statemachine)
      statemachine.context = @statemachine.context
      @startstate_ids << @startstate_id
      @startstate_id = nil
    end

    def get_statemachine_with(id)
      @parallel_statemachines.each do |s|
        return s if s.has_state(id)
      end
    end

    def get_transitions(event)
      transitions = []
      @transitions.each do |t|
        if t.event == event
          transitions << t
        end
      end
      if transitions.empty?
        return nil
      end
      transitions
    end

    def In(id)
      @parallel_statemachines.each do |s|
        return true if s.In(id.to_sym)
      end
      return false
    end

    def state= id
      @parallel_statemachines.each do |s|
        if s.has_state(id)
          s.state=id
          return true
        end
      end
      return false
    end

    def has_state(id)
      @parallel_statemachines.each do |s|
        if s.has_state(id)
          return true
        end
      end
      return false
    end

    def get_state(id)
      @parallel_statemachines.each do |s|
        if state = s.get_state(id)
          return state
        end
      end
      return nil
    end

    def process_event(event, *args)
      exceptions = []
      result = false

      # first check if the statemachine that currenlty executes the parallel state has a suitable transition
      if (@statemachine.which_state_respond_to? event)
        @statemachine.process_event(event,*args)
        result = true
      else  # otherwise check for local transitions inside parallel state

        @parallel_statemachines.each_with_index do |s,i|
          t = s.which_state_respond_to? event
          if s.respond_to? event
            s.process_event(event,*args)
            result = true
          end
        end
      end

      result
    end

    # Resets all of the statemachines back to theirs starting state.
    def reset
      @parallel_statemachines.each_with_index do |s,i|
        s.reset(@startstate_ids[i])
      end
    end

    def concrete?
      return true
    end

    def startstate
      return @statemachine.get_state(@startstate_id)
    end

    def resolve_startstate
      return self
    end

    def substate_exiting(substate)
      @history_id = substate.id
    end

    def add_substates(*substate_ids)
      do_substate_adding(substate_ids)
    end

    def default_history=(state_id)
      @history_id = @default_history_id = state_id
    end

    def states
      result =[]
      @parallel_statemachines.each  do |s|
        state = s.state
        r,p = s.belongs_to_parallel(state)
        if r
          result += p.states
        else
          result << state
        end
      end
      result
    end

    def transition_for(event,check_superstates=true)
      transition = super(event)
      if not transition
        @parallel_statemachines.each do |s|
          transition = s.get_state(s.state).non_default_transition_for(event,false)
          transition = s.get_state(s.state).default_transition if not transition
          return transition if transition
        end
        @superstate.transition_for(event,check_superstates) if (@superstate and check_superstates and @superstate!=self)
      else
        transition
      end
    end

    def enter(args=[])
      @statemachine.state = self
      @statemachine.trace("\tentering #{self}")

      if @entry_action != nil
        messenger = self.statemachine.messenger
        message_queue = self.statemachine.message_queue
        @statemachine.invoke_action(@entry_action, args, "entry action for #{self}", messenger, message_queue)
      end

      @parallel_statemachines.each_with_index do |s,i|
        s.activation = @statemachine.activation
        s.reset(@startstate_ids[i]) if not s.state
        s.get_state(@startstate_ids[i]).enter(args)
      end
    end

    def spontaneous_transition
      nil
    end


    def exit(args)
      @statemachine.trace("\texiting #{self}")

      if @exit_action != nil
        messenger = self.statemachine.messenger
        message_queue = self.statemachine.message_queue
        @statemachine.invoke_action(@exit_action, args, "exit action for #{self}", messenger, message_queue)
        @superstate.substate_exiting(self) if @superstate
      end

      @parallel_statemachines.each_with_index do |s,i|
        as = s.get_state(s.state)
        while as and as != self do
          as.exit(args)
          as = as.superstate
        end
        s.reset
      end
    end

    # explicit reset on parallel state entry
    def reset
      @parallel_statemachines.each_with_index do |s,i|
        s.reset(@startstate_ids[i])
      end
    end

    def to_s
      return "'#{id}' parallel"
    end

    def abstract_states
      abstract_states=[]

      if (@superstate)
        abstract_states=@superstate.abstract_states
      end

      abstract_states += [@id]

      @parallel_statemachines.each do |s|
        abstract_states += s.abstract_states + []
      end
      abstract_states.uniq
    end
    def is_parallel
      true
    end
  end

end
