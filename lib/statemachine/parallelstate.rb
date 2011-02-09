module Statemachine

  class Parallelstate< Superstate 
  
    attr_accessor :parallel_statemachines, :id
  
    def initialize(id, superstate, statemachine)
      super(id, superstate, statemachine)
      @parallel_statemachines=[]
    end

    def context= c
      @parallel_statemachines.each do |s|
         s.context=c
      end
    end

    def add_statemachine(statemachine)
      statemachine.is_parallel=self
      @parallel_statemachines.push(statemachine)
      statemachine.context = @statemachine.context
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
       @statemachine.get_state(id) 
    end

    def process_event(event, *args)
      exceptions = []
      @parallel_statemachines.each_with_index do |s,i|
        begin
          state = s.get_state(s.state)
          if state
            s.process_event(event,*args)
            @statemachine.state = s.state
          end
        rescue Exception => e
          exceptions.push e
        end
      end

      if exceptions.length<@parallel_statemachines.length
        return true
      else
        exceptions.each do |e|
          raise e
        end
      end
     end

    # Resets all of the statemachines back to theirs starting state.
    def reset
      @parallel_statemachines.each do |s|
        s.reset
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
        return transition   
      end
    end

    def enter(args=[])
      reset
      super(args)
    end
    def to_s
      return "'#{id}' parallel"
    end

    def abstract_states
      abstract_states={}
      @parallel_statemachines.each do |s|
        abstract_states.merge!(s.abstract_states)
      end
      abstract_states
    end
  end

end
