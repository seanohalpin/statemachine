module Statemachine


  class ParallelStatemachine 
    include ActionInvokation
        # Provides access to the +context+ of the statemachine.  The context is a object
    # where all actions will be invoked.  This provides a way to separate logic from
    # behavior.  The statemachine is responsible for all the logic and the context
    # is responsible for all the behavior.
    attr_reader :context

    def initialize(statemachines)
      @statemachines = statemachines
    end

    def states
#      puts @statemachines.length
      @statemachines.each.map &:state
    end
    
    def add(statemachine)
      @statemachines.push statemachine
    end

    def  process_event(event, *args)
      exceptions = []
      @statemachines.each_with_index do |s,i|
        begin 
          s.process_event(event,*args)
        rescue Exception => e  
          exceptions.push e
        end
      end
      
      if exceptions.length<@statemachines.length
        return true
      else
        exceptions.each do |e|
          raise e
        end
      end
    end
  
    def is_in_state?(id)
      @statemachines.each do |s|
        return true if s.is_in_state? id 
      end
      return false
    end
    
    def context=(context)
      @statemachines.each do |s|
        s.context=context
      end
    end

  end

end
