function signedarea(a, b, c)
    return imag(conj(a - b) * (a - c))
end

function test_intersection(p, q, a, b)

    ab_splits_pq = (signedarea(a, b, p) >= 0) != (signedarea(a, b, q) >= 0)
    pq_splits_ab = (signedarea(p, q, a) >= 0) != (signedarea(p, q, b) >= 0)

    return ab_splits_pq && pq_splits_ab
end

function intersection_number(path, segment)
    num = 0
    for pathseg in partition(path, 2, 1)
        num += test_intersection(pathseg..., segment...)
    end
    return num
end

#This function starts at the 'shoulder' (path[1]) and works in towards the 'foot' (path[end])
function path_sqrt(path::Vector{ComplexF64})
    branch = 1
    newpath = [sqrt(path[1])]
    cut = (0.0 + 0.0im, -1000 + 0.0im) #TODO this should be less arbitrary
    for segment in partition(path, 2, 1)
        if test_intersection(cut..., segment...)
            branch *= -1
        end
        append!(newpath, branch * sqrt(segment[2]))
    end
    return newpath
end
