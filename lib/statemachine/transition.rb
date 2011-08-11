module Statemachine

  class Transition #:nodoc:

    attr_reader :origin_id, :event, :action
    attr_accessor :destination_id, :cond

    def initialize(origin_id, destination_id, event, action, cond)
      @origin_id = origin_id
      @destination_id = destination_id
      @event = event
      @action = action
      @cond = cond
    end

    def invoke(origin, statemachine, args)
      destination = statemachine.get_state(@destination_id)
      exits, entries = exits_and_entries(origin, destination)
      exits.each { |exited_state| exited_state.exit(args) }
      messenger = origin.statemachine.messenger
      message_queue = origin.statemachine.message_queue

       if @action # changed this if statement to return if action fails
        if not origin.statemachine.invoke_action(@action, args, "transition action from #{origin} invoked by '#{@event}' event", messenger, message_queue)
          raise StatemachineException.new("Transition to state #{destination.id} failed because action for event #{@event} return false.")
        end
      end

#      origin.statemachine.invoke_action(@action, args, "transition action from #{origin} invoked by '#{@event}' event", messenger, message_queue) if @action

      terminal_state = entries.last

      terminal_state.activate if terminal_state and not terminal_state.is_parallel

      entries.each { |entered_state| entered_state.enter(args) }
      entries.each { |entered_state| entered_state.activate(terminal_state.id)  if entered_state.is_parallel }
      statemachine.state = terminal_state if statemachine.is_parallel

    end

    def exits_and_entries(origin, destination)
     # return [], [] if origin == destination
      exits = []
      entries = exits_and_entries_helper(exits, origin, destination)
      return exits, entries.reverse
    end

    def to_s
      return "#{@origin_id} ---#{@event}---> #{@destination_id} : #{action} if #{cond}"
    end

    private

    def exits_and_entries_helper(exits, exit_state, destination)
      entries = entries_to_destination(exit_state, destination)
      return entries if entries
      return [] if exit_state == nil

      exits << exit_state
      exits_and_entries_helper(exits, exit_state.superstate, destination)
    end

    def entries_to_destination(exit_state, destination)
      return nil if destination.nil?
      entries = []
      state = destination.resolve_startstate
      while state
        entries << state
        return entries if exit_state == state.superstate
        state = state.superstate
      end
      return nil
    end

  end

end