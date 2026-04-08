using Mandelbrot
using Test

@testset "Mandelbrot.jl" begin
    @test KneadingSequence(3//5) == KneadingSequence(2//5)

    @testset "Golden Tests" begin
        include(joinpath(@__DIR__, "..", "examples", "golden_tests.jl"))
    end
end
