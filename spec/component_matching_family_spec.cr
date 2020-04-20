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
    end
  end
end
