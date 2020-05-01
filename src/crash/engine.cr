require "event_handler"

module Crash
  class Engine
    include EventHandler
    @entities : Array(Crash::Entity)
    @systems : Array(Crash::System)
    @entity_names : Hash(String, Crash::Entity)
    @families : Hash(String, Crash::Family)
    @updating : Bool

    # Indicates if the engine is currently in its update loop.
    getter updating
    getter systems
    getter entities

    event UpdateCompleteEvent

    def initialize
      @entities = [] of Crash::Entity
      @systems = [] of Crash::System
      @entity_names = Hash(String, Crash::Entity).new
      @families = Hash(String, Crash::Family).new
      @updating = false
    end

    # Add an entity to the engine.
    def add_entity(entity : Crash::Entity)
      if @entity_names.has_key? entity.name
        raise Exception.new("The entity name #{entity.name} is already in use by another entity.")
      end
      @entities.push entity
      @entity_names[entity.name] = entity
      entity.on(Crash::Entity::NameChangedEvent) do |e|
        if @entity_names[e.old_name] === e.entity
          @entity_names.delete e.old_name
          @entity_names[e.entity.name] = e.entity
        end
      end
      entity.on(Crash::Entity::ComponentAddedEvent) do |e|
        @families.each do |_, family|
          family.component_added_to_entity e.entity, e.component_class
        end
      end
      entity.on(Crash::Entity::ComponentRemovedEvent) do |e|
        @families.each do |_, family|
          family.component_removed_from_entity e.entity, e.component_class
        end
      end
      @families.each do |_, family|
        family.new_entity entity
      end
    end

    # Remove an entity from the engine.
    def remove_entity(entity : Crash::Entity)
      entity.off Crash::Entity::NameChangedEvent
      entity.off Crash::Entity::ComponentAddedEvent
      entity.off Crash::Entity::ComponentRemovedEvent
      @families.each do |_, family|
        family.remove_entity entity
      end
      @entity_names.delete entity.name
      @entities.delete entity
    end

    # Remove all entities from the engine.
    def remove_all_entities
      while @entities.size > 0
        remove_entity @entities[0]
      end
    end

    # Get an entity based on its name.
    def get_entity_by_name(name : String) : Crash::Entity | Nil
      if @entity_names.has_key? name
        @entity_names[name]
      end
    end

    def add_system(system : Crash::System)
      add_system system, system.priority
    end

    # Add a system to the engine, and set its priority for the order in which the
    # systems are updated by the engine update loop.
    #
    # <p>The priority dictates the order in which the systems are updated by the engine update
    # loop. Lower numbers for priority are updated first. i.e. a priority of 1 is
    # updated before a priority of 2.</p>
    def add_system(system : Crash::System, priority : Int32)
      system.type = typeof(system)
      system.priority = priority
      system.add_to_engine self
      @systems.push system
      @systems.sort! do |a, b|
        next a.priority - b.priority
      end
    end

    # Remove a system from the engine.
    def remove_system(system : Crash::System)
      @systems.delete system
      system.remove_from_engine self
    end

    # Get the system instance of a particular type from within the engine.
    def get_system(type : Crash::System.class) : Crash::System | Nil
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

    protected def self.generate_family_key(*components : Crash::Component.class) : String
      sorted_comps = components.to_a.sort do |a, b|
        next -1 if a.name < b.name
        next 1 if a.name > b.name
        next 0
      end
      String.build do |io|
        sorted_comps.each do |comp|
          io << "+" << comp.name
        end
      end
    end

    # Get a collection of entities from the engine, based on the type of the components required.
    #
    # The engine will create the appropriate entity list if it doesn't already exist and
    # will keep its contents up to date as entities are added to and removed from the
    # engine.
    #
    # If a entity list is no longer required, release it with the release_entities method.
    def get_entities(*components : Crash::Component.class) : Array(Crash::Entity)
      key = Crash::Engine.generate_family_key(*components)

      if @families.has_key? key
        return @families[key].entity_list
      else
        # TODO: later we will allow creating custom families.
        family : Crash::Family = ComponentMatchingFamily.new(self, *components)
        @families[key] = family

        @entities.each do |entity|
          family.new_entity entity
        end
        return family.entity_list
      end
    end

    #
    # If a entity list is no longer required, this method will stop the engine updating
    # the list and will release all references to the list within the framework
    # classes, enabling it to be garbage collected.
    #
    # It is not essential to release a list, but releasing it will free
    # up memory and processor resources.
    #
    def release_entities(*components : Crash::Component.class)
      key = Crash::Engine.generate_family_key(*components)
      if @families.has_key? key
        @families[key].clean_up
      end
      @families.delete key
    end

    # Update the engine. This causes the engine update loop to run, calling update on all the
    # systems in the engine.
    #
    # If you need to pass variables to your systems you can extend this class.
    #
    # ## Example
    #
    # ````
    # # in your code
    # module Crash
    #   class Engine
    #     def update(*args : Float32)
    #       @updating = true
    #       @systems.each do |system|
    #         system.update(args)
    #       end
    #       @updating = false
    #       emit UpdateCompleteEvent
    #     end
    #   end
    # end
    # ```
    #
    # You can do the same for `System ` to then receive the args.
    # You can also add additional methds in this fashion. E.g. you could add an `input` method.
    #
    def update
      @updating = true
      @systems.each do |system|
        system.update
      end
      @updating = false
      emit UpdateCompleteEvent
    end
  end
end
