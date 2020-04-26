require "./spec_helper"

module Crash
  describe Crash do
    describe Crash::ComponentMatchingFamily do
      it "node list is initially empty" do
        engine = Engine.new
        family = ComponentMatchingFamily.new(MockNode, engine)
        family.node_list.size.should eq(0)
      end

      it "matching entity is added when access node list first time" do
        engine = Engine.new
        family = ComponentMatchingFamily.new(MockNode, engine)
        nodes = family.node_list
        entity = Entity.new
        entity.add(Point.new)
        family.new_entity(entity)
        nodes[0].entity.should be(entity)
      end

      it "matching entity is added when access node list second" do
        engine = Engine.new
        family = ComponentMatchingFamily.new(MockNode, engine)
        entity = Entity.new
        entity.add(Point.new)
        family.new_entity(entity)
        nodes = family.node_list
        nodes[0].entity.should be(entity)
      end

      it "node contains entity properties" do
        engine = Engine.new
        family = ComponentMatchingFamily.new(MockNode, engine)
        entity = Entity.new
        point = Point.new
        entity.add(point)
        family.new_entity(entity)
        nodes = family.node_list
        nodes[0].as(MockNode).point.should be(point)
      end

      it "matching entity is added when component is added" do
        engine = Engine.new
        family = ComponentMatchingFamily.new(MockNode, engine)
        nodes = family.node_list
        entity = Entity.new
        entity.add(Point.new)
        family.component_added_to_entity(entity, Point)
        nodes[0].entity.should be(entity)
      end

      it "non matching entity is not added" do
        engine = Engine.new
        family = ComponentMatchingFamily.new(MockNode, engine)
        entity = Entity.new
        family.new_entity entity
        nodes = family.node_list
        nodes.size.should eq(0)
      end

      it "entity is removed when access node list first" do
        engine = Engine.new
        family = ComponentMatchingFamily.new(MockNode, engine)
        entity = Entity.new
        entity.add Point.new
        family.new_entity entity
        nodes = family.node_list
        family.remove_entity(entity)
        nodes.size.should eq(0)
      end

      it "entity is removed when access node list second" do
        engine = Engine.new
        family = ComponentMatchingFamily.new(MockNode, engine)
        entity = Entity.new
        entity.add Point.new
        family.new_entity entity
        family.remove_entity(entity)
        nodes = family.node_list
        nodes.size.should eq(0)
      end

      it "entity is removed when component is removed" do
        engine = Engine.new
        family = ComponentMatchingFamily.new(MockNode, engine)
        entity = Entity.new
        entity.add Point.new
        family.new_entity entity
        entity.remove Point
        family.component_removed_from_entity(entity, Point)
        nodes = family.node_list
        nodes.size.should eq(0)
      end

      it "node list contains only matching entities" do
        engine = Engine.new
        family = ComponentMatchingFamily.new(MockNode, engine)
        entities = [] of Entity
        0.upto(5) do |i|
          entity = Entity.new
          entity.add Point.new
          entities.push entity
          family.new_entity entity
          family.new_entity Entity.new
        end

        nodes = family.node_list
        nodes.each do |node|
          entities.any? {|e| e == node.entity}.should eq(true)
        end
      end

      it "node list contains all matching entities" do
        engine = Engine.new
        family = ComponentMatchingFamily.new(MockNode, engine)
        entities = [] of Entity
        0.upto(5) do |i|
          entity = Entity.new
          entity.add Point.new
          entities.push entity
          family.new_entity entity
          family.new_entity Entity.new
        end

        nodes = family.node_list
        nodes.each do |node|
          entities.delete node.entity
        end
        entities.size.should eq(0)
      end

      it "clean up empties node list" do
        engine = Engine.new
        family = ComponentMatchingFamily.new(MockNode, engine)
        entity = Entity.new
        entity.add Point.new
        family.new_entity entity
        nodes = family.node_list
        family.clean_up
        nodes.size.should eq(0)
      end
    end
  end
end
