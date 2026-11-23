function signedarea(a, b, c)
    return imag(conj(a - b) * (a - c))
end

function onleft(a, b, c)
    area = signedarea(a, b, c)
    if iszero(area)
        #Edge case behavior to agree with IEEE sqrt
        σ(z) = iszero(imag(z)) ? (signbit(imag(z)) ? -1.0 : 1.0) : 0.0
        area = (real(b) - real(a)) * (σ(c) - σ(a)) - (σ(b) - σ(a)) * (real(c) - real(a))
    end
    return area >= 0
end

function crosscut(p, q)
    a = onleft(0.0 + 0.0im, 1.0 + 0.0im, p)
    b = onleft(0.0 + 0.0im, 1.0 + 0.0im, q)
    cut_splits_seg = (a != b)

    c = onleft(p, q, 0.0 + 0.0im)
    left_of_zero = (a == c)

    return cut_splits_seg && left_of_zero
end

function test_intersection(p, q, a, b)

    ab_splits_pq = onleft(a, b, p) != onleft(a, b, q)
    pq_splits_ab = onleft(p, q, a) != onleft(p, q, b)

    return ab_splits_pq && pq_splits_ab
end

function intersection_number(path, segment)
    num = 0
    for pathseg in partition(path, 2, 1)
        num += test_intersection(pathseg..., segment...)
    end
    return num
end

function intriangle(a, b, c, p)
    s = onleft(a, b, p)
    return s == onleft(b, c, p) && s == onleft(c, a, p)
end


function encloses(ua, ub, uf, va, vb, vf)
    if iszero(signedarea(va, vb, 0.0 + 0.0im))
        return false
    else
        #the foot lays in the triangle formed by the new segment and zero
        in_tri = intriangle(0.0 + 0.0im, ua, ub, uf)

        #the old segment splits the old foot from zero
        seg_splits = onleft(va, vb, vf) != onleft(va, vb, 0.0 + 0.0im)

        return in_tri && seg_splits
    end
end

function prune!(leg, feet)
    changed = true
    while changed
        changed = false
        k = 2
        while k < length(leg)
            if any(f -> intriangle(leg[k - 1], leg[k], leg[k + 1], f), feet)
                k += 1
            else
                deleteat!(leg, k)
                changed = true
            end
        end
    end
    return leg
end

function lift_segment!(out, va, vb, branch, feet, imgs, depth)
    if crosscut(va, vb)
        branch_b = branch * -1
    else
        branch_b = branch
    end

    ua = branch * sqrt(va)
    ub = branch_b * sqrt(vb)

    cross = any(k -> encloses(ua, ub, feet[k], va, vb, imgs[k]), eachindex(feet))

    if depth > 0 && cross
        vm = (va + vb) / 2
        branch_m = lift_segment!(out, va, vm, branch, feet, imgs, depth - 1)
        return lift_segment!(out, vm, vb, branch_m, feet, imgs, depth - 1)
    end
    push!(out, ub)
    return branch_b
end

function lift_leg(path, branch, feet, imgs; depth = 12)
    out = [branch * sqrt(path[1])]
    for k in 1:(length(path) - 1)
        branch = lift_segment!(out, path[k], path[k + 1], branch, feet, imgs, depth)
    end
    return out
end

function path_sqrt(path::Vector{ComplexF64})
    branch = 1
    newpath = [sqrt(path[1])]
    for segment in partition(path, 2, 1)
        if crosscut(segment[1], segment[2])
            branch *= -1
        end
        append!(newpath, branch * sqrt(segment[2]))
    end
    return newpath
end
