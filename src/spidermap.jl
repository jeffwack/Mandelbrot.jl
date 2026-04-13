struct Spider
    angle::Rational
    orbit::Sequence
    kneading_sequence::KneadingSequence
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
    points = length(leg)*length(leg[1])
    println(points)
    radius = sqrt(abs2(leg[1][1]))
    println(radius)
end

function sector(star1,star2,theta)
    if theta == star1
         return KneadingSymbol("*₁")
    elseif theta == star2
        return KneadingSymbol("*₂")
    elseif theta < star1 && theta > star2
        return KneadingSymbol("B")
    else
        return KneadingSymbol("A")
    end
end




    
function mapspider_angles(S::Spider)
    λ = S.legs[2][end] #the parameter of our polynomial map z -> λ(1+z/2)^2

    star1 = (angle(sqrt(S.legs[1][1]/λ))/(2*pi)+1)%1
    star2 = (star1 + 0.5)%1
    
    n = length(S.orbit.items)

    newLegs = Vector{Vector{ComplexF64}}(undef,n)

    #We are going to assume for now that angle=0 is always in region A and hope we can prove this later?
   
    sourceidxs = goestoidx(S.orbit)

    for ii in 1:n
        #first find the right half plane preimage of the shoulder
        sourceleg = S.legs[sourceidxs[ii]]
        u = sqrt(sourceleg[1]/λ)
        thetau = (angle(u)/(2*pi)+1)%1
        if S.kneading_sequence[ii] == sector(star1,star2,thetau) #then this is the correct preimage
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

function mapspider_boundary(S::Spider)
    λ = S.legs[2][end] #the parameter of our polynomial map z -> λ(1+z/2)^2

    n = length(S.orbit.items)

    newLegs = Vector{Vector{ComplexF64}}(undef,n)

    #now we calculate the boundary between A and b by taking the two preimages of the first leg which meet at -2

    firstsegment = 2.0 .*(path_sqrt(S.legs[1]./λ) .- 1.0)
    secondsegment = 2.0 .*(-1.0 .* path_sqrt(S.legs[1]./λ) .- 1.0)

    boundary = cat(firstsegment,reverse(secondsegment)[2:end],dims=1)

    #Now, for each leg, we take the preimage whose foot lays on the correct side of the boundary.
    #The region containing zero is in A by definition so we can test which region each point is in by computing intersections between the segment connecting the point to zero and the boundary.
    #Each leg needs to know: the kneading symbol 

    K = S.kneading_sequence

    if K.preperiod == 0
        return error("can't deal with periodic")
    end

    sourceidxs = goestoidx(S.orbit)
    
    #Assume preperiodic
    for ii in 1:n
        symb = K[ii]
        sourceleg = S.legs[sourceidxs[ii]]
        footone = 2.0*(sqrt(sourceleg[end]/λ) - 1.0)
        foottwo = 2.0*(-1.0*sqrt(sourceleg[end]/λ) - 1.0)
        if region(footone,boundary) == symb #reverses are here so that the path is taken from the foot out to the shoulder
            newLegs[ii] = 2.0 .* (reverse(path_sqrt(reverse(sourceleg)./λ)) .- 1.0)
        elseif region(foottwo,boundary) == symb
            newLegs[ii] = 2.0 .* (-1.0 .* reverse(path_sqrt(reverse(sourceleg)./λ)) .- 1.0)
        else
            error("something is wrong")
        end
    end  
        
    return Spider(S.angle,S.orbit,S.kneading_sequence,newLegs)
end
        
function spideriterates(S0::Spider,n_iter::Int)
    list = [S0]

    for i in 1:n_iter
        push!(list,mapspider_angles(list[end]))
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
function parameter(S0::Spider,max_iter::Int)
    S = deepcopy(S0)
    c_last = S.legs[2][end]/2 
    for ii in 1:max_iter
        mapspider!(S)
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
