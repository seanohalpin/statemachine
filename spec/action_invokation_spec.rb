require File.dirname(__FILE__) + '/spec_helper'
#require 'statemachine'
#require 'lib/statemachine/action_invokation.rb'
require "noodle"

describe "Action Invokation" do

  before(:each) do
    @noodle = Noodle.new
  end
  
  it "Proc actions" do
    sm = Statemachine.build do |smb|
      smb.trans :cold, :fire, :hot, Proc.new { @cooked = true }
    end
    
    sm.context = @noodle
    sm.fire
    
    @noodle.cooked.should equal(true)
  end
  
  it "Symbol actions" do
    sm = Statemachine.build do |smb|
      smb.trans :cold, :fire, :hot, :cook
      smb.trans :hot, :mold, :changed, :transform
    end
  
    sm.context = @noodle
    sm.fire
  
    @noodle.cooked.should equal(true)
    
    sm.mold "capellini"
    
    @noodle.shape.should eql("capellini")
  end

  it "String actions" do
    sm = Statemachine.build do |smb|
      smb.trans :cold, :fire, :hot, "@shape = 'fettucini'; @cooked = true"
    end
    sm.context = @noodle
    
    sm.fire
    @noodle.shape.should eql("fettucini")
    @noodle.cooked.should equal(true)
  end

  it "Multiple Proc actions" do
    sm = Statemachine.build do |smb|
      smb.trans :cold, :fire, :hot, [Proc.new { @cooked = true }, Proc.new { @tasty = true }]
    end

    sm.context = @noodle
    sm.fire

    @noodle.cooked.should equal(true)
    @noodle.tasty.should equal(true)
  end

  it "Multiple Symbol actions" do
    sm = Statemachine.build do |smb|
      smb.trans :cold, :fire, :hot, [:cook, :good]
    end

    sm.context = @noodle
    sm.fire

    @noodle.cooked.should equal(true)
    @noodle.tasty.should equal(true)
  end

  it "Multiple actions" do
    sm = Statemachine.build do |smb|
      smb.trans :cold, :fire, :hot, [:cook, Proc.new { @tasty = true }, "@shape = 'fettucini'"]
    end

    sm.context = @noodle
    sm.fire

    @noodle.cooked.should equal(true)
    @noodle.tasty.should equal(true)
    @noodle.shape.should eql("fettucini")
  end

  it "No actions" do
    sm = Statemachine.build do |smb|
      smb.trans :cold, :fire, :hot
    end

    sm.context = @noodle
    sm.fire

    @noodle.cooked.should == false
    @noodle.tasty.should == false
    @noodle.shape.should =="farfalla"
  end


end
