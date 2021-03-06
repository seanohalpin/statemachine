module Statemachine

  class StatemachineException < Exception
  end

  class TransitionMissingException < Exception
  end

  # Used at runtime to execute the behavior of the statemachine.
  # Should be created by using the Statemachine.build method.
  #
  #   sm = Statemachine.build do
  #     trans :locked, :coin, :unlocked
  #     trans :unlocked, :pass, :locked:
  #   end
  #
  #   sm.coin
  #   sm.state
  #
  # This class will accept any method that corresponds to an event.  If the
  # current state responds to the event, the appropriate transition will be invoked.
  # Otherwise an exception will be raised.
  class Statemachine
    include ActionInvokation

    # The tracer is an IO object.  The statemachine will write run time execution
    # information to the +tracer+. Can be helpful in debugging. Defaults to nil.
    attr_accessor :tracer

    # Provides access to the +context+ of the statemachine.  The context is a object
    # where all actions will be invoked.  This provides a way to separate logic from
    # behavior.  The statemachine is responsible for all the logic and the context
    # is responsible for all the behavior.
    attr_reader :context

    attr_reader :root, :states
    attr_accessor :messenger, :message_queue, :is_parallel #:nodoc:
    attr_accessor :activation

    # workaround that activation is not automatically set for parallel state machines
    def activation
      if is_parallel
        is_parallel.statemachine.activation
      else
        @activation
      end
    end

    # Should not be called directly.  Instances of Statemachine::Statemachine are created
    # through the Statemachine.build method.
    def initialize(root = Superstate.new(:root, nil, self))
      @root = root
      @states = {}
    end

    # Returns the id of the startstate of the statemachine.
    def startstate
      @root.startstate_id
    end

    # Resets the statemachine back to its starting state.
    def reset(startstate_id=nil, use_activation_callback = true)

      if (startstate_id and @root.is_parallel) # called when enterin a parallel state or dierctly entering a child of a parallel state from outside the parallel state
        @state = get_state(startstate_id)
      else
        @state = get_state(@root.startstate_id)
      end
      while @state and not @state.concrete?
        @state = get_state(@state.startstate_id)
      end
      raise StatemachineException.new("The state machine doesn't know where to start. Try setting the startstate.") if @state == nil
      @state.enter
      @state.activate
      @states.values.each { |state|
        state.reset if not state.is_a? Parallelstate
      }
      activation.call([@state.id],abstract_states,states_id) if  use_activation_callback and activation  and  not is_parallel
    end

    def context= c
      @context = c

      p = get_parallel
      if p
        p.context = c
      end
    end

    #Return the id of the current state of the statemachine.
    def state
      return @state.id if @state
      nil
    end

    # returns an array with the ids of the current active states of the machine.
    def states_id(atomic = true)
      belongs, parallel = belongs_to_parallel(@state.id)
      if belongs
        return parallel.states
      else
        return [@state.id]
      end
    end

    # returns an array with all currently active super states
    def abstract_states
      belongs, parallel = belongs_to_parallel(@state.id)
      if belongs
        return parallel.abstract_states
      end
      return @state.abstract_states
    end

    # You may change the state of the statemachine by using this method.  The parameter should be
    # the id of the desired state.
    def state= value
      if value.is_a? State
        @state = value
      elsif @states[value]
        @state = @states[value]
      elsif value and @states[value.to_sym]
        @state = @states[value.to_sym]
      end
    end

    def states= values
      if values.is_a? Array and values.length==1
        self.state=self.get_state(values.first)
      else
        values.each do |v|
          if @states.has_key? v
            self.state=v
          else
            belongs,parallel = belongs_to_parallel(v)
            if belongs
              self.state=parallel.id
              parallel.state=v
            end
          end
        end
      end
    end

    # The key method to exercise the statemachine. Any extra arguments supplied will be passed into
    # any actions associated with the transition.
    #
    # Alternatively to this method, you may invoke methods, names the same as the event, on the statemachine.
    # The advantage of using +process_event+ is that errors messages are more informative.
    def process_event(event, *args)
      event = event.to_sym
      trace "Event: #{event}"
      if @state

        transition = @state.transition_for(event)
        if transition
          if not transition.is_a? Array
            transition = [transition]
          end
          transition.each do |t|
            cond = true
            if t.cond != true
              cond = @state.statemachine.invoke_action(t.cond, [], "condition from #{@state} invoked by '#{event}' event", nil, nil)
            end
            if cond
              t.invoke(@state, self, args)
            end
          end
        else

          belongs, parallel = belongs_to_parallel(@state.id)
          if belongs
            r = parallel.process_event(event, *args)
            if r
              return true
            end
          end
          raise TransitionMissingException.new("#{@state} does not respond to the '#{event}' event.")

        end

      else
        raise StatemachineException.new("The state machine isn't in any state while processing the '#{event}' event.")
      end
    end

    def trace(message) #:nodoc:
      @tracer.puts message if @tracer
    end

    def belongs_to_parallel(id)
      @states.each_value do |v|
        # It doesn't belong to parallel, it is parallel
        return [true, v] if v.id == id and v.is_a? Parallelstate
        return [v.has_state(id),v] if v.is_a? Parallelstate
      end
      return [false, nil]
    end

    def get_parallel
      @states.each_value do |v|
        return v if v.is_a? Parallelstate
      end
      return false
    end

    def get_state(id) #:nodoc:
      if @states.has_key? id
        return @states[id]
      elsif(is_history_state_id?(id))
        superstate_id = base_id(id)
        if @is_parallel
          superstate = @is_parallel.get_state(superstate_id)
        else
          superstate = @states[superstate_id]
        end
        raise StatemachineException.new("No history exists for #{superstate} since it is not a super state.") if superstate.concrete?
        return load_history(superstate)
      elsif @is_parallel
        isp = @is_parallel
        @is_parallel = nil
        if isp.has_state(id)
          state = isp.get_state(id)
        elsif state = isp.statemachine.get_state(id)
          @is_parallel = isp
          return @is_parallel.statemachine.states[id] if @is_parallel.statemachine.states[id]
        end
        @is_parallel = isp
        return state
      elsif p = get_parallel and s = p.get_state(id)
        return s
      else
        if @root.is_a? Parallelstate
          return false
        end
        state = State.new(id, @root, self)
        @states[id] = state
        return state
      end
    end

    def add_state(state) #:nodoc:
      @states[state.id] = state
    end

    def remove_state(state)
      @states.delete(state.id)
    end

    def has_state(id) #:nodoc:
      if(is_history_state_id?(id))
        return @states.has_key?(base_id(id))
      else
        return @states.has_key?(id)
      end
    end

    def respond_to?(message)
      return true if super(message)
      return true if @state and @state.transition_for(message)
      return false
    end

    def which_state_respond_to?(message)
      #return super if super(message)
      return @state if  @state and @state.transition_for(message)
      nil
    end

    def method_missing(message, *args) #:nodoc:
      if @state and @state.transition_for(message)
        process_event(message.to_sym, *args)
        # method = self.method(:process_event)
        # params = [message.to_sym].concat(args)
        # method.call(*params)
      else
        begin        return super if super(message)

        super(message, args)
        rescue NoMethodError
          process_event(message.to_sym, *args)
        end
      end
    end

    def In(id)
      # check if it is one of the actual states
      return true if @state.id == id

      # check if it is one of the superstates
      return true if @state.has_superstate(id)

      # check if it is one of the running parallel states
      belongs, parallel = belongs_to_parallel(@state.id)
      if belongs
        parallel.In(id)
      end
    end

    private

    def is_history_state_id?(id)
      id.to_s[-2..-1] == "_H"
    end

    def base_id(history_id)
      history_id.to_s[0...-2].to_sym
    end

    def load_history(superstate)
      100.times do
        history = superstate.history_id ? get_state(superstate.history_id) :  get_state(superstate.startstate_id) #nil
        raise StatemachineException.new("#{superstate} doesn't have any history yet.") if not history
        if history.concrete?
          return history
        else
          superstate = history
        end
      end
      raise StatemachineException.new("No history found within 100 levels of nested superstates.")
    end

  end
end
