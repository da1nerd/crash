module Crash
  # The base class for a node.
  #
  # A node is a set of different components that are required by a system.
  # A system can request a collection of nodes from the engine. Subsequently the Engine object creates
  # a node for every entity that has all of the components in the node class and adds these nodes
  # to the list obtained by the system. The engine keeps the list up to date as entities are added
  # to and removed from the engine and as the components on entities change.
  #
  class Node
    # The entity whose components are included in the node.
    @entity : Entity?
    # @components : Hash(Component.class, Component)
    protected property entity

    def set_component(name : String, value : Component)
      {% begin %}
      {% for ivar in @type.instance_vars %}
        {% if ivar.name != "entity" && ivar.name != "components" %}
          if name == {{ivar.name.stringify}}
            @{{ivar.name}} = value.as({{ivar.type}})
            return
          end
        {% end %}
      {% end %}
    {% end %}
    end

    def self.components : Hash(Component.class, String)
      {% begin %}
        {% components = {} of Nil => Nil %}
        {% for ivar in @type.instance_vars %}
          {% if ivar.name != "entity" && ivar.name != "components" %}
            {% components[ivar.type] = ivar.name.stringify %}
          {% end %}
        {% end %}
        {{ components }} of Component.class => String
      {% end %}
    end

    # def components
    #   {{@type}}.components
    # end

    # def initialize
    #   @components = Hash(Component.class, Component).new
    # end
  end
end
