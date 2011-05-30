module Statemachine

  module ActionInvokation #:nodoc:

    def invoke_action(action, args, message, messenger, message_queue)
      if !(action.is_a? Array)
        action = [action]
      end
      result = true
      action.each {|a|
        if a.is_a? Symbol
          result = invoke_method(a, args, message)
        elsif a.is_a? Proc
          result = invoke_proc(a, args, message)
        elsif a.is_a? Array
          result = send(a[0],a[1])
        else
          log("#{a}")
          result =invoke_string(a) if not messenger
        end
        return false if result ==false
       }
      return result
    end

    private

    def send(target,event)
      if @message_queue
        @message_queue.send(target, event)
        return true
      end
      return false
    end

    def log(message)
      @messenger.puts message if @messenger
    end

    def invoke_method(symbol, args, message)
      method = @context.method(symbol)
      raise StatemachineException.new("No method '#{symbol}' for context. " + message) if not method

      parameters = params_for_block(method, args, message)
      method.call(*parameters)
    end

    def invoke_proc(proc, args, message)
      parameters = params_for_block(proc, args, message)
      @context.instance_exec(*parameters, &proc)
    end

    def invoke_string(expression)
      @context.instance_eval(expression)
    end

    def params_for_block(block, args, message)
      arity = block.arity
      required_params = arity < 0 ? arity.abs - 1 : arity

      raise StatemachineException.new("Insufficient parameters. (#{message})") if required_params > args.length

      return arity < 0 ? args : args[0...arity]
    end

  end

end

class Object

  module InstanceExecHelper; end

  include InstanceExecHelper

  def instance_exec(*args, &block) # !> method redefined; discarding old instance_exec
    mname = "__instance_exec_#{Thread.current.object_id.abs}_#{object_id.abs}"
    InstanceExecHelper.module_eval{ define_method(mname, &block) }
    begin
      ret = send(mname, *args)
    ensure
      InstanceExecHelper.module_eval{ undef_method(mname) } rescue nil
    end
    ret
  end

end