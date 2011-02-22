module Statemachine

  class Parallelstate< Superstate 
  
    attr_accessor :parallel_statemachines, :id
    attr_reader :startstate_ids

    def initialize(id, superstate, statemachine)
      super(id, superstate, statemachine)
      @parallel_statemachines=[]
      @startstate_ids=[]
    end

#    def startstate_id= id
#      if @parallel_statemachines.size>0
#        @startstate_ids[@parallel_statemachines.size-1]= id
#      end
#    end
#
#    def startstate_id
#      if (@parallel_statemachines.size>0 and @parallel_statemachines.size==@startstate_ids.size)
#        return true
#      end
#      nil
#    end

    def context= c
      @parallel_statemachines.each do |s|
         s.context=c
      end
    end

    def activate(terminal_state = nil)
      @statemachine.state = self

      @parallel_statemachines.each_with_index do |s,i|
        s.activation = @statemachine.activation
        s.reset(@startstate_ids[i])
      end
      @parallel_statemachines.each do |s|
        next if terminal_state and s.has_state(terminal_state)
        @statemachine.activation.call(s.state,self.abstract_states,self.states) if @statemachine.activation
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

    def non_default_transition_for(event)
      p "check parallel for #{event}"
      transition = @transitions[event]
      return transition if transition
      
      transition = transition_for(event)
      
      transition = @superstate.non_default_transition_for(event) if @superstate and not transition
      return transition
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
#      if state = @statemachine.get_state(id)
#        return state
#      end
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
      @parallel_statemachines.each_with_index do |s,i|
          if s.respond_to? event
            s.process_event(event,*args)
            result = true
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
      return @parallel_statemachines.map &:state
    end

    def transition_for(event)
      @parallel_statemachines.each do |s|
       # puts "checke parallel #{s.id} for #{event}"
        transition = s.get_state(s.state).non_default_transition_for(event)
        transition = s.get_state(s.state).default_transition if not transition
        return transition if transition
      end
      super.transition_for(event)
    end

    def enter(args=[])
     # reset
      super(args)
    end
    def to_s
      return "'#{id}' parallel"
    end

    def abstract_states
      abstract_states=[]

      if (@superstate)
        abstract_states=@superstate.abstract_states
      end
      @parallel_statemachines.each do |s|
        abstract_states += s.abstract_states
      end
      abstract_states.uniq
    end
    def is_parallel
      true
    end
  end

end
