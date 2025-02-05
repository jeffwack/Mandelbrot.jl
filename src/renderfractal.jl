function patch(center, right_center_displacement,N::Int) 
    #Overall strategy: 
    #First we will calculate a matrix of displacements from the center number.
    #This will be useful for the perturbation theory approach later, and the matrix we want for now 
    #can be obtained by simply adding the center parameter to the whole matrix.

    top_center_displacement = -1.0*im*right_center_displacement
    #points from the origin to the top of the frame

    horizontal_axis = LinRange(-right_center_displacement,right_center_displacement,N)
    vertical_axis = LinRange(-top_center_displacement,top_center_displacement,N)

    origin_patch = transpose(vertical_axis) .+ horizontal_axis

    return origin_patch .+ center
end 
 

struct EscapeTimeProblem
    z0::Number
    f::Function
    stop::Function
    maxiter::Int
end 

function escapetime(prob::EscapeTimeProblem)
    z = prob.z0
    for iter in 1:prob.maxiter
        if prob.stop(z) == true
            return (iter, z)
        else
            z = prob.f(z)
        end
    end
    return (NaN,z)
end

function forwardorbit(prob::EscapeTimeProblem)
    z = prob.z0
    O = [z]
    for iter in 1:prob.maxiter
        if prob.stop(z) == true
            return O
        else
            z = prob.f(z)
            push!(O,z)
        end
    end
    return O
end


function jproblem_array(patch::Matrix,f::Function,s::Function,maxiter::Int)
    PA = Array{EscapeTimeProblem}(undef,size(patch)...)
    for i in eachindex(patch)
        PA[i] = EscapeTimeProblem(patch[i],f,s,maxiter)
    end
    return PA
end

function mproblem_array(patch::Matrix,s::Function,maxiter::Int)
    PA = Array{EscapeTimeProblem}(undef,size(patch)...)
    for i in eachindex(patch)
        PA[i] = EscapeTimeProblem(patch[i],z->z*z+patch[i],s,maxiter)
    end
    return PA
end

function lproblem_array(patch::Matrix,s::Function,maxiter::Int)
    PA = Array{EscapeTimeProblem}(undef,size(patch)...)
    for i in eachindex(patch)
        PA[i] = EscapeTimeProblem(patch[i],z->2*patch[i]*(1+z/2)^2,s,maxiter)
    end
    return PA
end  

function normalize_escape_time!(patch::Matrix)
    patch = patch .- patch[1,1]
end

function blackwhite(alpha::Real)

    function color(z::Complex)
        turns = angle(z)/(2*pi) + 0.5
        if  turns >= alpha/2 && turns <alpha/2+0.5
            return 1
        else
            return 0
        end
    end

    return color

end

function escape(Radius::Real)

    function escaped(z::Number)
        if abs2(z) > Radius
            return true
        else
            return false
        end
    end

    return escaped
end

function escapeorconverge(Radius::Real)

    function escaped(z::Number)
        if abs2(z) > Radius || abs2(z) < 1/Radius
            return true
        else
            return false
        end
    end

    return escaped
end


function inverseiterate(c::Complex,steps::Int)
    preimages = ComplexF64[3.0+0.0im]
    for ii in 1:steps
        newpreimages = ComplexF64[] 
        for point in preimages
            push!(newpreimages,sqrt(point-c))
            push!(newpreimages,-sqrt(point-c))
        end
        preimages = newpreimages
    end
    return preimages
end

