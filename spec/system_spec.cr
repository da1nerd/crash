require "./spec_helper"

module Crash
  describe Crash::System do
    it "returns all the systems" do
      engine = Crash::Engine.new
      system1 = MockSystem.new
      engine.add_system system1, 1
      system2 = MockSystem.new
      engine.add_system system2, 1
      engine.systems.size.should eq(2)
      engine.systems.should eq([system1, system2])
    end

    it "removes a system from the engine" do
      engine = Crash::Engine.new
      system1 = MockSystem.new
      engine.add_system system1, 1
      engine.remove_system(system1)
      engine.systems.size.should eq(0)
    end

    it "engine calls update on systems" do
      engine = Crash::Engine.new
      system1 = MockSystem.new
      engine.add_system system1, 0
      engine.update
      system1.time.should eq(0.1)
    end

    it "system default priority is 0" do
      system = MockSystem.new
      system.priority.should eq(0)
      engine = Crash::Engine.new
      engine.add_system system
      system.priority.should eq(0)
    end

    it "can set priority when adding a system" do
      system = MockSystem.new
      system.priority.should eq(0)
      engine = Crash::Engine.new
      engine.add_system system, 1
      system.priority.should eq(1)
    end

    it "systems update in priority order if same as add order" do
      engine = Crash::Engine.new
      system1 = MockSystem.new
      engine.add_system system1, 1
      system2 = MockSystem.new
      engine.add_system system2, 2
      engine.update
      # TODO: test order
    end

    it "systems update in priority order if reverse of add order" do
      engine = Crash::Engine.new
      system2 = MockSystem.new
      engine.add_system system2, 2
      system1 = MockSystem.new
      engine.add_system system1, 1
      engine.update
      # TODO: test order
    end

    it "systems update in priority order if priorities are negative" do
      engine = Crash::Engine.new
      system1 = MockSystem.new
      engine.add_system system1, 1
      system2 = MockSystem.new
      engine.add_system system2, -2
      engine.update
      # TODO: test order
    end

    it "updating is false before update" do
      engine = Engine.new
      engine.updating.should eq(false)
    end

    it "updating is true during update" do
      engine = Engine.new
      system = MockSystem.new
      engine.add_system(system)
      # TODO: test if updating is true
      engine.update
    end

    it "updating is false after update" do
      engine = Engine.new
      engine.update
      engine.updating.should eq(false)
    end

    it "complete signal is dispatched after update" do
      emitted = false
      engine = Engine.new
      engine.on(Engine::UpdateCompleteEvent) do
        emitted = true
      end
      system = MockSystem.new
      engine.add_system system, 0
      emitted.should eq(false)
      engine.update
      emitted.should eq(true)
    end

    it "get_system returns the system" do
      engine = Engine.new
      system = MockSystem.new
      engine.add_system system
      engine.get_system(MockSystem).should eq(system)
    end

    it "get_system returns nil if there is no system" do
      engine = Engine.new
      engine.get_system(MockSystem).should eq(nil)
    end

    it "get_system returns nil if there is no matching system" do
      engine = Engine.new
      engine.add_system MockSystem2.new
      engine.get_system(MockSystem).should eq(nil)
    end

    it "removes all systems" do
      engine = Engine.new
      engine.add_system MockSystem2.new
      engine.add_system MockSystem.new
      engine.remove_all_systems
      engine.get_system(MockSystem).should eq(nil)
      engine.get_system(MockSystem2).should eq(nil)
    end
  end
end
