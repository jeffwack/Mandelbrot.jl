struct Spider
    angle::Rational
    orbit::Sequence
    kneading_sequence::Sequence{KneadingSymbol{4}}
    legs::Vector{Vector{ComplexF64}}
end

function Base.show(io::IO, S::Spider)
    npoints = sum([length(leg) for leg in S.legs])
    return println("A " * repr(S.angle) * "-spider with kneading sequence " * repr(S.kneading_sequence) * " and " * repr(npoints) * " points.")
end

function standardspider(theta)
    orb = orbit(theta)
    K = thetaitinerary(theta, orb) #the kneading sequence is calculated like so to avoid recalculating the orbit of theta
    legs = standardlegs(orb)
    return Spider(theta, orb, K, legs)
end

function standardlegs(orbit::Sequence)
    r = collect(LinRange(1, 100, 10))  #NOTE - it may be better to keep this as a 'linrange' but I don't understand what that means
    legs = Vector{ComplexF64}[]
    for theta in orbit.items
        push!(legs, (cos(theta * 2 * pi) + 1.0im * sin(theta * 2 * pi)) .* r)
    end
    legs[1] = legs[1] .- legs[1][1]

    return legs
end

function stats(legs::Vector{Vector{ComplexF64}})
    println("~~~~~~~~~~~~~~~~~~~~")
    λ = legs[2][1]
    println(λ / 2)
    points = sum(length.(legs))
    println(points)
    radius = sqrt(abs2(legs[1][end]))
    return println(radius)
end

function spidermap(S::Spider; R = 1.0e6)
    λ = S.legs[2][1] #the parameter of our polynomial map z -> λ(1+z/2)^2

    legs = [leg ./ λ for leg in S.legs]
    feet = [leg[1] for leg in legs]
    #now z2 is at 1, z1 is still at 0

    #Computing the new feet
    n = length(S.orbit.items)
    newfeet = Vector{ComplexF64}(undef, n)

    branches = ones(Int, n)

    #w_1
    newfeet[1] = 1

    sourceidxs = goestoidx(S.orbit)
    critical = S.orbit.preperiod == 0 ? n : 0
    for ii in 2:n
        source_foot = feet[sourceidxs[ii]]
        num = intersection_number(legs[1], (1.0 + 0.0im, source_foot))
        sg = (-1)^(num - S.kneading_sequence[ii].value + 1)
        branches[ii] = sg
        newfeet[ii] = sg * sqrt(source_foot)
    end

    #Lifting the legs
    newLegs = Vector{Vector{ComplexF64}}(undef, n)
    for ii in 1:n
        path = legs[sourceidxs[ii]]

        others = [k for k in 1:n if k != ii]

        imgs = feet[sourceidxs][others]
        obs = newfeet[others]

        if ii == critical
            probe = lift_leg(path[2:end], 1, ComplexF64[], ComplexF64[])[end]
            probeisstar2 = onleft(0.0 + 0.0im, newLegs[1][end], probe)
            wantstar2 = S.kneading_sequence[ii] == KneadingSymbol{4}("*₂")
            if probeisstar2 == wantstar2
                branch = 1
            else
                branch = -1
            end
            newLegs[ii] = [0.0 + 0.0im; lift_leg(path[2:end], branch, obs, imgs)]
        else
            newLegs[ii] = lift_leg(path, branches[ii], obs, imgs)
        end
    end

    for ii in 1:n
        others = [k for k in 1:n if k != ii]
        obs = newfeet[others]
        prune!(newLegs[ii], obs)
    end

    for leg in newLegs
        leg .+= (-1.0 + 0.0im)
        leg .*= (2.0 + 0.0im)
        push!(leg, R * leg[end] / abs(leg[end]))
    end

    return Spider(S.angle, S.orbit, S.kneading_sequence, newLegs)
end

function spideriterates(S0::Spider, n_iter::Int)
    list = [S0]

    for i in 1:n_iter
        push!(list, spidermap(list[end]))
    end
    return list
end

"""
    parameter(S0::Spider, max_iter::Int)
    parameter(theta::Rational, max_iter::Int)

Computes the parameter (center) of a hyperbolic component using the spider algorithm 
described in [Hubbard_Schleicher_1995](@cite).

For a given external angle θ, this iteratively applies the spider map until convergence
to find the parameter c at the center of the corresponding hyperbolic component.

# References
- [Hubbard_Schleicher_1995](@cite): The spider algorithm
"""
function parameter(S::Spider, max_iter::Int; rtol::Real = 8 * eps())
    c_last = S.legs[2][1] / 2
    for ii in 1:max_iter
        S = spidermap(S)
        c = S.legs[2][1] / 2
        if abs(c - c_last) <= rtol * max(1, abs(c))
            return c
        end
        c_last = c
    end
    @warn "The spider algorithm did not converge in $max_iter iterations; returning the last iterate." S.angle rtol
    return S.legs[2][1] / 2
end

function parameter(theta::Rational, max_iter::Int; kwargs...)
    return parameter(standardspider(theta), max_iter; kwargs...)
end
