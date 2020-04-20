module Crash
  class Engine
    @entities : Array(Entity)
    @systems : Array(System)
    @entity_names : Hash(String, Entity)
    @families : Hash(Node.class, Family)
    @updating : Bool

    # Indicates if the engine is currently in its update loop.
    getter updating
    getter systems

    def initialize
      @entities = [] of Entity
      @systems = [] of System
      @entity_names = Hash(String, Entity).new
      @families = Hash(Node.class, Family).new
      @updating = false
    end

    # Add an entity to the engine.
    def add_entity(entity : Entity)
      if @entity_names.has_key? entity.name
        raise Exception.new("The entity name #{entity.name} is already in use by another entity.")
      end
      @entities.push entity
      @entity_names[entity.name] = entity
      # entity.component_added.add( componentAdded )
      # entity.componentRemoved.add( componentRemoved );
      # entity.nameChanged.add( entityNameChanged );
      @families.each do |node_class, family|
        family.new_entity entity
      end
    end

    # Remove an entity from the engine.
    def remove_entity(entity : Entity)
      # destroy nodes containing this entity's components
      # and remove them from the node lists
      @entities.remove(entity)
    end

    # Remove all entities from the engine.
    def remove_all_entities
      @entities.clear
    end

    # Get an entity based on its name.
    def get_entity_by_name(name : String) : Entity | Nil
      @entity_names[name]
    end

    def add_system(system : System)
      add_system system, system.priority
    end

    # Add a system to the engine, and set its priority for the order in which the
    # systems are updated by the engine update loop.
    #
    # <p>The priority dictates the order in which the systems are updated by the engine update
    # loop. Lower numbers for priority are updated first. i.e. a priority of 1 is
    # updated before a priority of 2.</p>
    def add_system(system : System, priority : Int32)
      system.type = typeof(system)
      system.priority = priority
      system.add_to_engine self
      @systems.push system
      @systems.sort! do |a, b|
        next a.priority - b.priority
      end
    end

    # Remove a system from the engine.
    def remove_system(system : System)
      @systems.delete system
      system.remove_from_engine self
    end

    # Get the system instance of a particular type from within the engine.
    def get_system(type : System.class) : System | Nil
      @systems.each do |system|
        return system if system.type == type
      end
    end

    # Remove all systems from the engine.
    def remove_all_systems
      @systems.each do |system|
        system.remove_from_engine(self)
      end
      @systems.clear
    end

    # Get a collection of nodes from the engine, based on the type of the node required.
    #
    # The engine will create the appropriate NodeList if it doesn't already exist and
    # will keep its contents up to date as entities are added to and removed from the
    # engine.
    #
    # If a NodeList is no longer required, release it with the releaseNodeList method.
    def get_node_list(node_class : Node.class) : Array(Node)
      if @families.has_key? node_class
        return @families[node_class].node_list
      end

      # TODO: later we will allow creating custom families.
      family : Family = ComponentMatchingFamily.new(node_class, self)
      families[node_class] = family

      @entities.each do |index, entity|
        family.new_entity entity
      end
      return family.node_list
    end

    #
    # If a NodeList is no longer required, this method will stop the engine updating
    # the list and will release all references to the list within the framework
    # classes, enabling it to be garbage collected.
    #
    # It is not essential to release a list, but releasing it will free
    # up memory and processor resources.
    #
    def release_node_list(node_class : Node.class)
      if families.has_key? node_class
        families[node_class].clean_up
      end
      families.delete node_class
    end

    # Update the engine. This causes the engine update loop to run, calling update on all the
    # systems in the engine.
    #
    # The package net.richardlord.ash.tick contains classes that can be used to provide
    # a steady or variable tick that calls this update method.
    def update(time : Float64)
      @updating = true
      @systems.each do |system|
        system.update(time)
      end
      @updating = false
    end
  end
end
