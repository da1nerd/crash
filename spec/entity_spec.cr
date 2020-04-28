require "./spec_helper"

module Crash
  describe Crash::Entity do
    it "add returns reference to entity" do
      entity = Entity.new
      component = MockComponent.new
      entity.add(component).should be(entity)
    end

    it "can store and retrieve a component" do
      entity = Entity.new
      component = MockComponent.new
      entity.add(component)
      entity.get(MockComponent).should be(component)
    end

    it "can store and retrieve multiple components" do
      entity = Entity.new
      component1 = MockComponent.new
      entity.add(component1)
      component2 = MockComponent2.new
      entity.add(component2)
      entity.get(MockComponent).should be(component1)
      entity.get(MockComponent2).should be(component2)
    end

    it "can replace a component" do
      entity = Entity.new
      component1 = MockComponent.new
      entity.add(component1)
      component2 = MockComponent.new
      entity.add(component2)
      entity.get(MockComponent).should be(component2)
    end

    it "can store base and extended components" do
      entity = Entity.new
      component1 = MockComponent.new
      entity.add(component1)
      component2 = MockComponentExtended.new
      entity.add(component2)
      entity.get(MockComponent).should be(component1)
      entity.get(MockComponentExtended).should be(component2)
    end

    it "can store extended component as base type" do
      entity = Entity.new
      component = MockComponentExtended.new
      entity.add(component, MockComponent)
      entity.get(MockComponent).should be(component)
    end

    it "get return null if no component" do
      entity = Entity.new
      entity.get(MockComponent).should eq(nil)
    end

    it "will retrieve all components" do
      entity = Entity.new
      component1 = MockComponent.new
      entity.add(component1)
      component2 = MockComponent2.new
      entity.add(component2)
      components = entity.get_all
      components.size.should eq(2)
      components.should eq([component1, component2])
    end

    it "has component is false if component type is not present" do
      entity = Entity.new
      component1 = MockComponent.new
      entity.add(component1)
      entity.has(MockComponent2).should eq(false)
    end

    it "has component is true if component type is present" do
      entity = Entity.new
      component1 = MockComponent.new
      entity.add(component1)
      entity.has(MockComponent).should eq(true)
    end

    it "can remove component" do
      entity = Entity.new
      component = MockComponent.new
      entity.add(component)
      entity.remove(MockComponent)
      entity.has(MockComponent).should eq(false)
    end

    it "storing component triggers added signal" do
      emitted = false
      entity = Entity.new
      entity.on(Entity::ComponentAddedEvent) do |e|
        emitted = true
      end
      component = MockComponent.new
      entity.add(component)
      emitted.should eq(true)
    end

    it "removing component triggers removed signal" do
      emitted = false
      entity = Entity.new
      entity.on(Entity::ComponentRemovedEvent) do |e|
        emitted = true
      end
      component = MockComponent.new
      entity.add(component)
      entity.remove(MockComponent)
      emitted.should eq(true)
    end
  end
end
