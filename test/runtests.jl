using Mandelbrot
using Test

@testset "Mandelbrot.jl" begin

    @test Mandelbrot.Sequence{Mandelbrot.KneadingSymbol{3}}(KneadingSequence(3 // 5)) == Mandelbrot.Sequence{Mandelbrot.KneadingSymbol{3}}(KneadingSequence(2 // 5))

    @test address(InternalAddress(KneadingSequence(1 // 3))) == [1, 2]
    @test address(InternalAddress(KneadingSequence(1 // 7))) == [1, 3]
    @test length(leaf_vertices(HubbardTree(InternalAddress([1, 2])))) == 2

    H = HubbardTree(InternalAddress([1, 3]))
    @test length(leaf_vertices(H)) == 3
    @test length(branch_vertices(H)) == 1

end
