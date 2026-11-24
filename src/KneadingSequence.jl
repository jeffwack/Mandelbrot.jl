struct KneadingSymbol{N}
    value::Int
    function KneadingSymbol{N}(value::Int) where {N}
        1 <= value <= N || error("Value must be in range [1, $N]")
        return new{N}(value)
    end
end

Base.hash(k::KneadingSymbol{N}, h::UInt64) where {N} = hash((N, k.value), h)

const KNEADING_ALPHABETS = Dict(
    2 => ["A", "B"],
    3 => ["A", "B", "*"],
    4 => ["A", "B", "*₁", "*₂"],
)

function KneadingSymbol{N}(s::String) where {N}
    idx = findfirst(==(s), KNEADING_ALPHABETS[N])
    idx === nothing && error("\"$s\" is not in the $N-symbol alphabet")
    return KneadingSymbol{N}(idx)
end

function Base.show(io::IO, k::KneadingSymbol{N}) where {N}
    return print(io, KNEADING_ALPHABETS[N][k.value])
end

# Convert 2->3 (embed: A,B stay as A,B)
function KneadingSymbol{3}(k::KneadingSymbol{2})
    return KneadingSymbol{3}(k.value)
end

# Convert 4->3 (forget: both stars collapse to single star)
function KneadingSymbol{3}(k::KneadingSymbol{4})
    if k.value <= 2  # A or B
        return KneadingSymbol{3}(k.value)
    else  # *₁ or *₂ both become *
        return KneadingSymbol{3}(3)
    end
end

# Identity: 3→3
KneadingSymbol{3}(k::KneadingSymbol{3}) = k

function Sequence{KneadingSymbol{3}}(seq::Sequence{KneadingSymbol{4}})
    return Sequence{KneadingSymbol{3}}(KneadingSymbol{3}.(seq.items), seq.preperiod)
end

function Sequence{KneadingSymbol{3}}(seq::Sequence{KneadingSymbol{2}})
    symblist = KneadingSymbol{3}.(copy(seq.items))
    pre = seq.preperiod
    if seq.preperiod == 0
        symblist[end] = KneadingSymbol{3}("*")
    end
    return Sequence{KneadingSymbol{3}}(symblist, seq.preperiod)
end

"""
A kneading sequence is a combinatorial description of the orbit of an angle under doubling. For an angle theta,
the kneading sequence of theta is defined as the theta itinerary of theta.
"""
const KneadingSequence = Sequence{<:KneadingSymbol}

function KneadingSequence(angle)
    orb = orbit(angle)
    return thetaitinerary(angle, orb)
end

# I don't like how this 'bakes in' *2
function orbit(angle::T) where {T}
    items = T[]

    while !(angle in items)
        push!(items, angle)
        angle = angle * 2 % 1
    end

    preperiod = findall(x -> x == angle, items)[1] - 1

    return Sequence{T}(items, preperiod)

end

#what is this for?
function orbit(a::Vector{Rational{Int}})
    items = Vector{Rational}[]
    while isempty(findall(x -> x == a, items))
        push!(items, a)
        a = [(angle * 2) % 1 // 1 for angle in a]
    end

    preperiod = findall(x -> x == a, items)[1] - 1

    return Sequence{Vector{Rational}}(items, preperiod)

end

function orbit(seq::Sequence)
    items = Sequence[]

    while isempty(findall(x -> x == seq, items))
        push!(items, seq)
        seq = shift(seq)
    end

    preperiod = findall(x -> x == seq, items)[1] - 1

    return Sequence{Sequence}(items, preperiod)
end


function thetaitinerary(theta, angle)
    return thetaitinerary(theta, orbit(angle))
end

function thetaitinerary(theta, orb::Sequence)
    a = theta / 2
    b = theta / 2 + 1 // 2
    itinerary = KneadingSymbol{4}[]

    for angle in orb.items
        if angle == a
            push!(itinerary, KneadingSymbol{4}("*₁"))
        elseif angle == b
            push!(itinerary, KneadingSymbol{4}("*₂"))
        elseif angle > a && angle < b
            push!(itinerary, KneadingSymbol{4}("A"))
        else
            push!(itinerary, KneadingSymbol{4}("B"))
        end
    end

    return Sequence{KneadingSymbol{4}}(itinerary, orb.preperiod)
end


struct Digit{N} #<: Integer #not sure why I wanted this to be a subtype of integer
    value::Int
    function Digit{N}(value::Int) where {N}
        m = N - 1
        0 <= value < N || error("Value must be in range [0, $m]")
        return new{N}(value)
    end
end

Base.hash(d::Digit, h::UInt64) = hash(d.value, h)
Base.string(d::Digit) = Base.string(d.value) #defined because the show method for sequences calls string() on the items
Base.show(io::IO, d::Digit{N}) where {N} = print(io, d.value)
Base.Int(d::Digit) = d.value

function Base.isless(a::Digit{M}, b::Digit{N}) where {M, N}
    if M == N
        return Base.isless(Int(a), Int(b))
    else
        return error("can't compare Digit{$M} and Digit{$N}")
    end
end

const BinaryExpansion = Sequence{Digit{2}}

""" The binary expansion of an angle is a sequence of 1s and 0s which can be interpreted either as place-value representation of the angle, or as an itinerary of the angle under angle doubling.
"""
function BinaryExpansion(theta)
    orb = orbit(theta % 1)
    itinerary = Digit{2}[]
    zero = Digit{2}(0)
    one = Digit{2}(1)
    for theta in orb.items
        if theta < 1 // 2
            push!(itinerary, zero)
        else
            push!(itinerary, one)
        end
    end
    return Sequence{Digit{2}}(collect(itinerary), orb.preperiod)
end

function Base.isless(a::Sequence{Digit{N}}, b::Sequence{Digit{N}}) where {N}
    if a == b
        return false
    else
        ii = 1
        while a[ii] == b[ii]
            ii += 1
        end
        return isless(a[ii], b[ii])
    end
end


function Base.Rational(bits::BinaryExpansion)
    theta = 0 // 1
    k = bits.period
    r = 1 // (1 // 1 - (2 // 1)^-k)
    for (ii, digit) in enumerate(bits.items)
        if digit == Digit{2}(1)
            if ii <= bits.preperiod
                theta += (2 // 1)^(-ii)
            else
                theta += r * (2 // 1)^(-ii)
            end
        end
    end
    return theta
end

function thetaitinerary(theta::BinaryExpansion, orb::Sequence)
    a = prepend(theta, 0)
    b = prepend(theta, 1)
    itinerary = KneadingSymbol{4}[]

    for angle in orb.items
        if angle == a
            push!(itinerary, KneadingSymbol{4}("*₁"))
        elseif angle == b
            push!(itinerary, KneadingSymbol{4}("*₂"))
        elseif angle > a && angle < b
            push!(itinerary, KneadingSymbol{4}("A"))
        else
            push!(itinerary, KneadingSymbol{4}("B"))
        end
    end

    return Sequence{KneadingSymbol{4}}(itinerary, orb.preperiod)

end

#The vertical bars play the role of the overbar indicating the periodic part of a decimal expansion
#Printing an overbar is possible but looked ugly, so I opted for these vertical bars instead.
#They are intended to evoke musical repeat symbols.
function Base.show(io::IO, K::KneadingSequence)
    str = [string(item) for item in K.items]
    L = K.preperiod
    if L == 0
        return print(io, "|", str..., "|")
    else
        return print(io, str[1:L]..., "|", str[(L + 1):end]..., "|")
    end
end

#The vertical bars play the role of the overbar indicating the periodic part of a decimal expansion
#Printing an overbar is possible but looked ugly, so I opted for these vertical bars instead.
#They are intended to evoke musical repeat symbols.
function Base.show(io::IO, K::BinaryExpansion)
    str = [string(item) for item in K.items]
    L = K.preperiod
    if L == 0
        return print(io, "|", str..., "|")
    else
        return print(io, str[1:L]..., "|", str[(L + 1):end]..., "|")
    end
end
