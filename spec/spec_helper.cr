require "spec"
require "../src/crash"
require "./components/**"
require "./systems/**"

class MockSystem < Crash::System
    @time : Float64 = 0
    getter time

    def update(@time : Float64)
    end
end