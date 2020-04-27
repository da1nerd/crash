require "./family"

module Crash
  #
  # The default class for managing a NodeList. This class creates the NodeList and adds and removes
  # nodes to/from the list as the entities and the components in the engine change.
  #
  # It uses the basic entity matching pattern of an entity system - entities are added to the list if
  # they contain components matching all the public properties of the node class.
  #
  class ComponentMatchingFamily < Family
    @entities : Array(Entity)
    @entity_map : Hash(Entity, Bool)
    @component_to_name_map : Hash(Crash::Component.class, String)
    @name_to_component_map : Hash(String, Crash::Component.class)
    @engine : Engine

    #
    # The constructor. Creates a ComponentMatchingFamily to provide a NodeList for the
    # given node class.
    #
    # @param nodeClass The type of node to create and manage a NodeList for.
    # @param engine The engine that this family is managing teh NodeList for.
    #
    def initialize(@engine : Engine, *components : Crash::Component.class)
      @name_to_component_map = Hash(String, Crash::Component.class).new
      @component_to_name_map = Hash(Crash::Component.class, String).new
      @entity_map = Hash(Entity, Bool).new
      @entities = [] of Entity
      components.each do |c|
        @name_to_component_map[c.name] = c
        @component_to_name_map[c] = c.name
      end
    end

    #
    # The entity list managed by this family. This is a reference that remains valid always
    # since it is retained and reused by Systems that use the list. i.e. we never recreate the list,
    # we always modify it in place.
    #
    def entity_list : Array(Entity)
      @entities
    end

    #
    # Called by the engine when an entity has been added to it. We check if the entity should be in
    # this family's entity list and add it if appropriate.
    #
    def new_entity(entity : Entity)
      add_if_match entity
    end

    #
    # Called by the engine when a component has been added to an entity. We check if the entity is not in
    # this family's entity list and should be, and add it if appropriate.
    #
    def component_added_to_entity(entity : Entity, component_class : Component.class)
      add_if_match entity
    end

    #
    # Called by the engine when a component has been removed from an entity. We check if the removed component
    # is required by this family's entity list and if so, we check if the entity is in this this entity list and
    # remove it if so.
    #
    def component_removed_from_entity(entity : Entity, component_class : Component.class)
      if @component_to_name_map.has_key? component_class
        remove_if_match entity
      end
    end

    #
    # Called by the engine when an entity has been rmoved from it. We check if the entity is in
    # this family's entity list and remove it if so.
    #
    def remove_entity(entity : Entity)
      remove_if_match entity
    end

    #
    # If the entity is not in this family's entity list, tests the components of the entity to see
    # if it should be in this entity list and adds it if so.
    #
    private def add_if_match(entity : Entity)
      if !@entity_map.has_key?(entity)
        @component_to_name_map.keys.each do |component_class|
          return unless entity.has component_class
        end
        @entity_map[entity] = true
        @entities << entity
      end
    end

    #
    # Removes the entity if it is in this family's entity list.
    #
    private def remove_if_match(entity : Entity)
      if @entity_map.has_key? entity
        @entity_map.delete entity
        @entities.delete entity
      end
    end

    #
    # Removes all entities from the entity list.
    #
    def clean_up
      @entities.clear
      @entity_map.clear
    end
  end
end
