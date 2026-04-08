using Mandelbrot
using Test

@testset "Mandelbrot.jl" begin
    for f in filter(f -> endswith(f, ".jl") && f != "runtests.jl", readdir(@__DIR__))
        @testset "$f" begin
            include(f)
        end
    end
end
