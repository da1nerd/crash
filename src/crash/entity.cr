require "event_handler"

module Crash
  # Utility to track the entity count.
  # We need this because class variable values don't persist between subclasses.
  class EntityCounter
    @@count : Int32 = 0

    # Adds 1 to the count
    protected def self.increment
      @@count += 1
    end

    # Returns the count value
    protected def self.count
      @@count
    end

    # Resets the counter
    protected def self.reset
      @@count = 0
    end
  end

  class Entity
    include EventHandler
    @name : String
    @components : Hash(Crash::Component.class, Crash::Component)
    protected getter name

    # Dispatched when a component is added to the entity
    event ComponentAddedEvent, entity : Crash::Entity, component_class : Crash::Component.class

    # Dispatched when a component is removed from the entity
    event ComponentRemovedEvent, entity : Crash::Entity, component_class : Crash::Component.class

    # Dispatched when the name of the entity changes.
    # Used internally by the engine to track entitites based on their names.
    event NameChangedEvent, entity : Crash::Entity, old_name : String

    def initialize
      Crash::EntityCounter.increment
      initialize "_entity#{Crash::EntityCounter.count}"
    end

    def initialize(@name : String)
      @components = Hash(Crash::Component.class, Crash::Component).new
    end

    def name=(name : String)
      if @name != name
        previous = @name
        @name = name
        emit NameChangedEvent, self, previous
      end
    end

    #
    # Add a component to the entity.
    #
    # @param component The component object to add.
    # @param componentClass The class of the component. This is only necessary if the component
    # extends another component class and you want the framework to treat the component as of
    # the base class type. If not set, the class type is determined directly from the component.
    #
    # @return A reference to the entity. This enables the chaining of calls to add, to make
    # creating and configuring entities cleaner. e.g.
    #
    # <code>var entity : Entity = new Entity()
    #     .add( new Position( 100, 200 )
    #     .add( new Display( new PlayerClip() );</code>
    #
    def add(component : Crash::Component, component_class : Crash::Component.class)
      if @components.has_key? component_class
        remove component_class
      end
      @components[component_class] = component
      emit ComponentAddedEvent, self, component_class
      self
    end

    def add(component : Crash::Component)
      add component, typeof(component)
    end

    def remove(component_class : Crash::Component.class)
      if @components.has_key? component_class
        component = @components[component_class]
        @components.delete component_class
        emit ComponentRemovedEvent, self, component_class
        return component
      end
    end

    # Get a component from the entity.
    def get(component_class : Crash::Component.class) : Crash::Component | Nil
      if @components.has_key? component_class
        return @components[component_class]
      end
    end

    # Get all components from the entity.
    def get_all
      @components.values
    end

    #
    # Does the entity have a component of a particular type.
    #
    # @param componentClass The class of the component sought.
    # @return true if the entity has a component of the type, false if not.
    #
    def has(component_class : Crash::Component.class) : Bool
      return @components.has_key? component_class
    end
  end
end
