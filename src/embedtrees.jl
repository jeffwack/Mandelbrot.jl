struct EmbeddedHubbardTree
    htree::OrientedHubbardTree
    angle::Rational
    rays::Dict{BinaryExpansion, Vector{ComplexF64}}
    parameter::ComplexF64
    vertices::Dict{Sequence{KneadingSymbol{3}}, ComplexF64}
    edges::Dict{Set{Sequence{KneadingSymbol{3}}}, Tuple{Sequence{KneadingSymbol{3}}, Vector{ComplexF64}}}
end

function EmbeddedHubbardTree(OHT::OrientedHubbardTree; refinements = 5)

    anglelist = allanglesof(OHT)

    theta = rationalangle(first(criticalanglesof(OHT)))
    c = parameter(standardspider(theta), 1000)

    #critical orbit
    rays = Dict()
    #periodic branch points
    characteristicpoints = characteristicset(OHT)
    for point in characteristicpoints
        merge!(rays, dynamicrays(c, first(anglelist[point]), 100, 10, 20))
    end

    #preperiod branch points. This is slow!
    for node in keys(OHT.adj)
        for angle in anglelist[node]
            if !(angle in keys(rays))
                push!(rays, Pair(angle, dynamicrays(c, angle, 100, 10, 20)[angle]))
            end
        end
    end

    merge!(rays, dynamicrays(c, BinaryExpansion(1 // 2), 100, 10, 40))
    merge!(rays, dynamicrays(c, BinaryExpansion(0 // 1), 100, 10, 40))

    paramorbit = [0.0 + 0.0im]
    n = period(theta)
    #println(n)
    for _ in 1:(n - 1)
        push!(paramorbit, paramorbit[end]^2 + c)
    end
    #println(paramorbit)

    zvalues = Dict{Sequence, ComplexF64}()
    for node in keys(OHT.adj)
        if KneadingSymbol{3}("*") in node.items #then it is in the critical orbit
            idx = findone(x -> x == KneadingSymbol{3}("*"), node.items)
            push!(zvalues, Pair(node, paramorbit[mod1(n - idx + 2, n)]))
        else
            list = [rays[angle][end] for angle in anglelist[node]]
            push!(zvalues, Pair(node, sum(list) / length(list)))
        end
    end
    E = standardedges(OHT.adj, OHT.criticalpoint, zvalues)
    H = EmbeddedHubbardTree(OHT, theta, rays, c, zvalues, E)
    for _ in 1:refinements
        refinetree!(H)
    end
    return H
end

function EmbeddedHubbardTree(theta::Rational; refinements = 5)
    return EmbeddedHubbardTree(OrientedHubbardTree(theta); refinements = refinements)
end

function Base.show(io::IO, H::EmbeddedHubbardTree)
    return println(io, "Embedded Hubbard tree of " * repr(H.angle) * " with " * repr(length(H.vertices)) * " vertices")
end

function standardedges(adj, zero, zvalues)
    edges = edgeset(adj)

    edgevectors = []
    for edge in edges
        start = first(filter(z -> z != zero, edge))
        finish = first(filter(z -> z != start, edge))
        push!(edgevectors, Pair(edge, (start, [zvalues[start], zvalues[finish]])))
    end
    return Dict(edgevectors)
end

function longpath(EHT, start, finish)
    nodes = nodepath(EHT.htree, start, finish)
    edges = edgepath(EHT.htree, start, finish)

    edgevectors = EHT.edges

    longpath = ComplexF64[]

    for (ii, edge) in enumerate(edges)
        if edgevectors[edge][1] == nodes[ii]
            if ii != 1
                append!(longpath, edgevectors[edge][2][2:end])
            else
                append!(longpath, edgevectors[edge][2])
            end
        else
            if ii != 1
                append!(longpath, reverse(edgevectors[edge][2])[2:end])
            else
                append!(longpath, reverse(edgevectors[edge][2]))
            end
        end
    end

    return longpath

end

function edgepath(graph, start, finish)
    vertexpath = nodepath(graph, start, finish)
    return [Set(E) for E in partition(vertexpath, 2, 1)]
end

function refinetree!(EHT)
    for edge in keys(EHT.edges)
        start = EHT.edges[edge][1]
        finish = first(filter(x -> x != start, edge))
        #determine the image of this edge
        image = longpath(EHT, shift(start), shift(finish))

        refinedimage = [image[1]]
        for point in image[2:end]
            push!(refinedimage, (refinedimage[end] + point) / 2)
            push!(refinedimage, point)
        end

        c = EHT.parameter
        x = sqrt(-c + refinedimage[1])

        if abs2(x - EHT.edges[edge][2][1]) < abs2(-x - EHT.edges[edge][2][1])
            EHT.edges[edge] = (start, path_sqrt(-c .+ refinedimage))
        else
            EHT.edges[edge] = (start, -path_sqrt(-c .+ refinedimage))
        end
    end
    return EHT
end
