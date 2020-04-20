require "./spec_helper"

module Crash
  describe Crash::Engine do
    it "entities getter returns all the entities" do
      engine = Engine.new
      entity1 = Entity.new
      engine.add_entity entity1
      entity2 = Entity.new
      engine.add_entity entity2
      engine.entities.size.should eq(2)
      engine.entities.should eq([entity1, entity2])
    end

    it "get entity by name returns correct entity" do
      engine = Engine.new
      entity1 = Entity.new("otherEntity")
      engine.add_entity entity1
      entity2 = Entity.new("myEntity")
      engine.add_entity entity2
      engine.get_entity_by_name("myEntity").should eq(entity2)
    end

    it "get entity by name should return nil if no entity" do
      engine = Engine.new
      entity1 = Entity.new("otherEntity")
      engine.add_entity entity1
      entity2 = Entity.new("myEntity")
      engine.add_entity entity2
      engine.get_entity_by_name("wrongName").should eq(nil)
    end

    it "add entity checks with all families" do
      engine = Engine.new
      engine.get_node_list(MockNode)
      engine.get_node_list(MockNode2)
      entity = Entity.new
      engine.add_entity entity
      # TODO: check calls
    end

    it "remove entity checks with all families" do
      engine = Engine.new
      engine.get_node_list(MockNode)
      engine.get_node_list(MockNode2)
      entity = Entity.new
      engine.add_entity entity
      engine.remove_entity entity
      # TODO: check calls
    end

    it "remove all entities checks with all families" do
      engine = Engine.new
      engine.get_node_list(MockNode)
      engine.get_node_list(MockNode2)
      engine.add_entity Entity.new
      engine.add_entity Entity.new
      engine.remove_all_entities
      # TODO: test calls
    end

    it "component added checks with all families" do
      engine = Engine.new
      engine.get_node_list(MockNode)
      engine.get_node_list(MockNode2)
      entity = Entity.new
      engine.add_entity entity
      entity.add(MockComponent.new)
      # TODO: test calls
    end

    it "component removed checks with all families" do
      engine = Engine.new
      engine.get_node_list(MockNode)
      engine.get_node_list(MockNode2)
      entity = Entity.new
      engine.add_entity entity
      entity.add(MockComponent.new)
      entity.remove(MockComponent)
      # TODO: test calls
    end

    it "get node list creates family" do
      engine = Engine.new
      engine.get_node_list MockNode
      # TODO: test calls
    end

    it "get node list checks all entities" do
      engine = Engine.new
      engine.add_entity Entity.new
      engine.add_entity Entity.new
      engine.get_node_list MockNode
      # TODO: test
    end

    it "release node list calls cleanup" do
      engine = Engine.new
      engine.get_node_list MockNode
      engine.release_node_list MockNode
      # TODO: test
    end

    it "entity can be obtained by name" do
      engine = Engine.new
      entity = Entity.new("anything")
      engine.add_entity entity
      other = engine.get_entity_by_name "anything"
      other.should be(entity)
    end

    it "get entity by invalid name returns nil" do
      engine = Engine.new
      other = engine.get_entity_by_name "anything"
      other.should be(nil)
    end

    it "entity can be obtained by name after renaming" do
      engine = Engine.new
      entity = Entity.new("anything")
      engine.add_entity entity
      entity.name = "otherName"
      other = engine.get_entity_by_name "otherName"
      other.should be(entity)
    end

    it "entity cannot be obtained by old name after renaming" do
      engine = Engine.new
      entity = Entity.new("anything")
      engine.add_entity entity
      entity.name = "otherName"
      other = engine.get_entity_by_name "anything"
      other.should be(nil)
    end
  end
end
