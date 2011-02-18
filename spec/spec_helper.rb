$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'rubygems'
require 'spec'
require 'statemachine'

$IS_TEST = true

def check_transition(transition, origin_id, destination_id, event, action)
  transition.should_not equal(nil)
  transition.event.should equal(event)
  transition.origin_id.should equal(origin_id)
  transition.destination_id.should equal(destination_id)
  transition.action.should eql(action)
end

module SwitchStatemachine

  def create_switch
    @status = "off"
    @sm = Statemachine.build do
      trans :off, :toggle, :on, Proc.new { @status = "on" }
      trans :on, :toggle, :off, Proc.new { @status = "off" }
    end
    @sm.context = self
  end

end

module ParallelStatemachine

  def create_parallel

     @cooked = "false"
     @out_of_order = false

     @sm = Statemachine.build do
      trans :start,:go,:p
      state :maintenance
      parallel :p do
        statemachine :s1 do
          superstate :operative do
            trans :locked, :coin, :unlocked, Proc.new {  @cooked = true }
            trans :unlocked, :coin, :locked
            event :maintain, :maintenance, Proc.new { @out_of_order = true }
          end
        end
        statemachine :s2 do
          superstate :onoff do
            trans :on, :toggle, :off
            trans :off, :toggle, :on
          end
        end
      end
    end
    @sm.context = self
  end

  def create_tick
    @status = "off"
    @sm = Statemachine.build do
      trans :off, :toggle, :on
      trans :on, :toggle, :off
      state :on do
         on_entry Proc.new { @sm.toggle }
      end

    end
    @sm.context = self
  end

   def create_tome
    @sm = Statemachine.build do
      trans :me, :toggle, :me
    end
    @sm.context = self
  end
end



module TurnstileStatemachine

  def create_turnstile
    @locked = true
    @alarm_status = false
    @thankyou_status = false
    @lock = "@locked = true;true"
    @unlock = "@locked = false;true"
    @alarm = "@alarm_status = true;true"
    @thankyou = "@thankyou_status = true;true"

    @sm = Statemachine.build do
      trans :locked, :coin, :unlocked, "@locked = false;true"
      trans :unlocked, :pass, :locked, "@locked = true;true"
      trans :locked, :pass, :locked, "@alarm_status = true;true"
      trans :unlocked, :coin, :locked, "@thankyou_status = true;true"
    end
    @sm.context = self
  end

end

TEST_DIR = File.expand_path(File.dirname(__FILE__) + "/../test_dir/")

def test_dir(name = nil)
  Dir.mkdir(TEST_DIR) if !File.exist?(TEST_DIR)
  return TEST_DIR if name.nil?
  dir = File.join(TEST_DIR, name)
  Dir.mkdir(dir) if !File.exist?(dir)
  return dir
end

def remove_test_dir(name)
  system "rm -rf #{test_dir(name)}" if File.exist?(test_dir(name))
end

def load_lines(*segs)
  filename = File.join(*segs)
  File.should exist( filename)
  return IO.read(filename).split("\n")
end
