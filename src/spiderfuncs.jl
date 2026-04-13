
#This function starts at the 'shoulder' (path[1]) and works in towards the 'foot' (path[end])
function path_sqrt(path::Vector{ComplexF64})
    branch = 1
    newpath = [sqrt(path[1])]
    cut = (0.0 + 0.0im, -1000 + 0.0im)
    for segment in partition(path,2,1)
        if test_intersection(cut...,segment...)
            branch *= -1
        end
        append!(newpath,branch*sqrt(segment[2]))
    end
    return newpath
end

function test_intersection(z1::Complex,z2::Complex,w1::Complex,w2::Complex)
    
    x1 = real(z1)
    y1 = imag(z1)

    x2 = real(z2)
    y2 = imag(z2)

    x3 = real(w1)
    y3 = imag(w1)

    x4 = real(w2)
    y4 = imag(w2)

    tn = (x1 - x3)*(y3 - y4) - (y1 - y3)*(x3 - x4)
    un = (x1 - x3)*(y1 - y2) - (y1 - y3)*(x1 - x2)
    d = (x1 - x2)*(y3 - y4) - (y1 - y2)*(x3 - x4)

    if d == 0
        return false
    elseif sign(tn)*sign(d) == -1
        return false
    elseif sign(un)*sign(d) == -1
        return false
    elseif abs2(tn) > abs2(d)
        return false
    elseif abs2(un) > abs2(d)
        return false
    else
        return true
    end

end
