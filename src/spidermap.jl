struct Spider
    angle::Rational
    orbit::Sequence
    kneading_sequence::Sequence{KneadingSymbol{4}}
    legs::Vector{Vector{ComplexF64}}
end

function Base.show(io::IO, S::Spider)
    npoints = sum([length(leg) for leg in S.legs])
    return println("A "*repr(S.angle)*"-spider with kneading sequence "*repr(S.kneading_sequence)*" and "*repr(npoints)*" points.")
end

function standardspider(theta)
    orb = orbit(theta)
    K = thetaitinerary(theta,orb) #the kneading sequence is calculated like so to avoid recalculating the orbit of theta
    legs = standardlegs(orb)
    return Spider(theta,orb,K,legs)
end

function standardlegs(orbit::Sequence)
    r = collect(LinRange(100,1,10))  #NOTE - it may be better to keep this as a 'linrange' but I don't understand what that means
    legs  = Vector{ComplexF64}[]
    for theta in orbit.items
        push!(legs,(cos(theta*2*pi)+1.0im*sin(theta*2*pi)) .* r)
    end
    #legs[1] .+= -legs[1][end]
    return legs
end

function grow!(legs::Vector{Vector{ComplexF64}},scale::Real,num::Int)
    #Get the arrow pointing from the second to last point to the last point
    for leg in legs
        arrow = scale*(leg[1]-leg[2])
        #add new elements which are the last element plus the arrow
        for i in 1:num
            pushfirst!(leg,leg[1]+arrow)
        end
    end
end


function prune!()
end

function stats(legs::Vector{Vector{ComplexF64}})
    println("~~~~~~~~~~~~~~~~~~~~")
    λ = legs[2][end]
    println(λ/2)
    points = sum(length.(legs))
    println(points)
    radius = sqrt(abs2(legs[1][1]))
    println(radius)
end

function sector(boundary1, boundary2, theta, phi)                                                                                                                                # Shift everything so boundary1 sits at 0
    b = mod(boundary2 - boundary1, 1)   # for a diameter, this is 0.5                                                                                                      
    t = mod(theta - boundary1, 1)
    p = mod(phi - boundary1, 1)                                                                                                                                            

    if p == b
        if t<b
            return KneadingSymbol{4}("*₂")
        else
            return KneadingSymbol{4}("*₁")
        end
    elseif p == 0
        if t<b
            return KneadingSymbol{4}("*₁")
        else
            return KneadingSymbol{4}("*₂")
        end
    end                                                                                                                                                                    
   
    # Same region iff both fall on the same side of b                                                                                                                      
    if (t < b) == (p < b)
        return KneadingSymbol{4}("A")
    else
        return KneadingSymbol{4}("B")
    end                                                                                                           
  end    
    
function spider_map(S::Spider)
    λ = S.legs[2][end] #the parameter of our polynomial map z -> λ(1+z/2)^2

    star1 = (angle(sqrt(S.legs[1][1]/λ))/(2*pi)+1)%1
    star2 = (star1 + 0.5)%1
    
    n = length(S.orbit.items)

    newLegs = Vector{Vector{ComplexF64}}(undef,n)

    newLegs[1] = reverse(path_sqrt(reverse(S.legs[2])./λ)) #reverse so that path_sqrt goes from foot to shoulder

    #println(abs(newLegs[1][end]-1.0)) #This should be zero
    
    thetaA = (angle(newLegs[1][1])/(2*pi)+1)%1 #gives the angle of the shoulder in full turns
    #this angle lays in region A by definition.
   
    sourceidxs = goestoidx(S.orbit)

    for ii in 2:n
        #first find the right half plane preimage of the shoulder
        sourceleg = S.legs[sourceidxs[ii]]
        u = sqrt(sourceleg[1]/λ)
        thetau = (angle(u)/(2*pi)+1)%1
        if S.kneading_sequence[ii] == sector(star1,star2,thetaA,thetau) #then this is the correct preimage
            newLegs[ii] = path_sqrt(sourceleg./λ)
        else
            newLegs[ii] = -1 .* path_sqrt(sourceleg./λ)
        end
    end
    
    for leg in newLegs
        leg .+= (-1.0+0.0im)
        leg .*= (2.0+0.0im)
    end
    
    grow!(newLegs,10,10)

    return Spider(S.angle,S.orbit,S.kneading_sequence,newLegs)
end
        
function spideriterates(S0::Spider,n_iter::Int)
    list = [S0]

    for i in 1:n_iter
        push!(list, spider_map(list[end]))
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
#TODO modify below to have tolerance-based convergence behavior
function parameter(S::Spider,max_iter::Int)
    c_last = S.legs[2][end]/2 
    for ii in 1:max_iter
        S = spider_map(S)
        c = S.legs[2][end]/2
        #println(repr(c)*" delta "*repr(abs(c-c_last)))
        if abs(c-c_last)<(1e-15)
            return c
        end
        c_last = c
    end
    return S.legs[2][end]/2 
end

function parameter(theta::Rational,max_iter::Int)
    return parameter(standardspider(theta),max_iter)
end
