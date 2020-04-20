require "./spec_helper"

module Crash
    describe Crash::System do

        it "returns all the systems" do
            engine = Crash::Engine.new
            system1 = Crash::System.new
            engine.add_system system1, 1
            system2 = Crash::System.new
            engine.add_system system2, 1
            engine.systems.size.should eq(2)
            engine.systems.should eq([system1, system2])
        end

        it "removes a system from the engine" do
            engine = Crash::Engine.new
            system1 = Crash::System.new
            engine.add_system system1, 1
            engine.remove_system(system1)
            engine.systems.size.should eq(0)
        end

        it "engine calls update on systems" do
            engine = Crash::Engine.new
            system1 = MockSystem.new
            engine.add_system system1, 0
            engine.update(0.1)
            system1.time.should eq(0.1)
        end

        it "system default priority is 0" do
            system = Crash::System.new
            system.priority.should eq(0)
            engine = Crash::Engine.new
            engine.add_system system
            system.priority.should eq(0)
        end

        it "can set priority when adding a system" do
            system = Crash::System.new
            system.priority.should eq(0)
            engine = Crash::Engine.new
            engine.add_system system, 1
            system.priority.should eq(1)
        end

        it "systems update in priority order if same as add order" do
            engine = Crash::Engine.new
            system1 = Crash::System.new
            engine.add_system system1, 1
            system2 = Crash::System.new
            engine.add_system system2, 2
            engine.update(0.1)
            # TODO: test order
        end

        it "systems update in priority order if reverse of add order" do
            engine = Crash::Engine.new
            system2 = Crash::System.new
            engine.add_system system2, 2
            system1 = Crash::System.new
            engine.add_system system1, 1
            engine.update(0.1)
            # TODO: test order
        end

        it "systems update in priority order if priorities are negative" do
            engine = Crash::Engine.new
            system1 = Crash::System.new
            engine.add_system system1, 1
            system2 = Crash::System.new
            engine.add_system system2, -2
            engine.update(0.1)
            # TODO: test order
        end

        it "updating is false before update" do
            engine = Engine.new
            engine.updating.should eq(false)
        end

        it "updating is true during update" do
            engine = Engine.new
            system = System.new
            engine.add_system(system)
            # TODO: test if updating is true
            engine.update(1.0)
        end

        it "updating is false after update" do
            engine = Engine.new
            engine.update(1.0)
            # TODO: test if updating is false
        end

        it "complete signal is dispatche after update" do
            # TODO: test
        end

        it "get_system returns the system" do
        end

        it "get_system returns nil if there is no system" do
            engine = Engine.new
            engine.get_system(MockSystem).should eq(Nil)
        end
    end
end