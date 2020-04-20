require "spec"
require "../src/crash"

class MockSystem < Crash::System
  @time : Float64 = 0
  getter time

  def update(@time : Float64)
  end
end

class MockNode < Crash::Node
end

class MockNode2 < Crash::Node
end

class MockComponent < Crash::Component
end
