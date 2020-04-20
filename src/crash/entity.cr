module Crash
  class Entity
    @@name_count : Int32 = 0
    @name : String
    @components : Hash(Component.class, Component)

    protected getter name

    def initialize
      @@name_count += 1
      initialize "_entity#{@@name_count}"
    end

    def initialize(@name : String)
      @components = Hash(Component.class, Component).new
    end

    def name=(name : String)
      if @name != name
        previous = @name
        @name = name
        # TODO: dispatch
      end
    end

    def add(component : Component)
      component_class = typeof(component)
      if @components.has_key? component_class
        remove component_class
      end
      @components[component_class] = component
      # TODO: dispatch event
      self
    end

    def remove(component_class : Component.class)
      if @components.has_key? component_class
        component = @components[component_class]
        @components.delete component_class
        # TODO: dispatch event
        return component
      end
    end

    def get(component_class : Component.class) : Component
      return @components[component_class]
    end

    #
    # Does the entity have a component of a particular type.
    #
    # @param componentClass The class of the component sought.
    # @return true if the entity has a component of the type, false if not.
    #
    def has(component_class : Component.class) : Bool
      return @components[component_class] != nil
    end
  end
end
