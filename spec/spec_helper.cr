require "spec"
require "../src/crash"

class MockSystem < Crash::System
  @time : Float64 = 0
  getter time

  def update(@time : Float64)
  end
end

class MockSystem2 < Crash::System
end

class MockNode < Crash::Node
  @point : Point
  getter point

  def initialize
    super()
    @point = Point.new
  end
end

class MockNode2 < Crash::Node
end

class Point < Crash::Component
  @x : Int32 = 1
  @y : Int32 = 3
end

class MockComponent < Crash::Component
  @x : Int32 = 1
  @y : Int32 = 3
end

class MockComponent2 < Crash::Component
end

class MockComponentExtended < MockComponent
end
