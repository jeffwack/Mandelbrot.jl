using Mandelbrot
using Test

@testset "Mandelbrot.jl" begin

    @testset "Kneading Sequences" begin
        @test Mandelbrot.Sequence{Mandelbrot.KneadingSymbol{3}}(KneadingSequence(3 // 5)) == Mandelbrot.Sequence{Mandelbrot.KneadingSymbol{3}}(KneadingSequence(2 // 5))
    end

    @testset "Internal Addresses" begin
        @test Vector(InternalAddress(KneadingSequence(1 // 3))) == [1, 2]
        @test Vector(InternalAddress(KneadingSequence(1 // 7))) == [1, 3]
        @test length(leafvertices(HubbardTree(InternalAddress([1, 2])))) == 2

        H = HubbardTree(InternalAddress([1, 3]))
        @test length(leafvertices(H)) == 3
        @test length(branchvertices(H)) == 1
    end

    @testset "Angle round-trips" begin
        function roundtrip(theta)
            return BinaryExpansion(theta) in Mandelbrot.criticalanglesof(OrientedHubbardTree(AngledInternalAddress(theta)))
        end

        @test roundtrip(19 // 127)
        @test roundtrip(12 // 31)
        @test roundtrip(5 // 31)
        @test roundtrip(2 // 9)
        @test roundtrip(7 // 19)
        @test roundtrip(6 // 7)
    end

    @testset "Spiders" begin
        function lands(theta, z)
            return isapprox(parameter(theta, 1000), z; atol = 1.0e-12)
        end
        @test lands(1 // 3, -1.0 + 0.0im)
        @test lands(1 // 7, -0.12256116687665362 + 0.7448617666197442im)
        @test lands(2 // 7, -0.12256116687665362 + 0.7448617666197442im)
        @test lands(6 // 7, -0.12256116687665362 - 0.7448617666197442im)
        @test lands(3 // 7, -1.7548776662466927 + 0.0im)
        @test lands(1 // 15, 0.2822713907669139 + 0.5300606175785253im)
        @test lands(7 // 15, -1.9407998065294847 + 0.0im)
        @test lands(12 // 31, -1.2563679300681807 + 0.3803209634727225im)
        @test lands(19 // 127, 0.014895466603687646 + 0.8481487619084165im)
        @test lands(1 // 63, 0.38900684056977125 + 0.21585065087081912im)
        @test lands(1 // 2, -2.0 + 0.0im)
        @test lands(1 // 4, -0.22815549365396182 + 1.1151425080399373im)
        @test lands(1 // 6, 0.0 + 1.0im)
        @test lands(5 // 12, -1.5436890126920764 + 0.0im)
        @test lands(9 // 56, -0.10109636384562216 + 0.9562865108091415im)
    end

end
