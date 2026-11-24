"""An internal address is an increasing sequence of integers which describes a kneading sequence"""
struct InternalAddress
    addr::Vector{Int}
end

function InternalAddress(n::Rational)
    return InternalAddress(KneadingSequence(n))
end

function InternalAddress(K::KneadingSequence)
    return InternalAddress(rhosequence(K, 1))
end

#Works only for finite internal addresses
function KneadingSequence(intadd::InternalAddress)
    address = copy(intadd.addr)
    if address == [1]
        return Sequence{KneadingSymbol{2}}([KneadingSymbol{2}("A")], 0)
    else
        s = pop!(address)
        K = KneadingSequence(InternalAddress(address))
        R = K.items[mod1.(1:(s - 1), end)]
        if K.items[mod1(s, end)] == KneadingSymbol{2}("A")
            push!(R, KneadingSymbol{2}("B"))
        else
            push!(R, KneadingSymbol{2}("A"))
        end
        return Sequence{KneadingSymbol{2}}(R, 0)
    end
end

Base.Vector(IA::InternalAddress) = copy(IA.addr)

function Base.length(intadd::InternalAddress)
    return length(intadd.addr)
end

function Base.getindex(intadd::InternalAddress, n::Int)
    return intadd.addr[n]
end

#TreesBook pg 21 def 2.2
function rho(K::KneadingSequence)
    function rho_nu(n::Int)
        if K.preperiod == 0 && mod(n, K.period) == 0
            return Inf
        end
        q = n + 1
        while K[q] == K[q - n]
            q = q + 1
        end
        return q
    end
    return rho_nu
end

#works only for strictly periodic kneading sequences
function rhosequence(K::KneadingSequence, n::Int)
    if K.preperiod == 0
        seq = Vector{Int}([n])
        rho_nu = rho(K)
        while rho_nu(seq[end]) !== Inf
            append!(seq, rho_nu(seq[end]))
        end
        return seq
    else
        error("cant deal with preperiodic")
    end
end


function admissible(K::KneadingSequence, m::Int)
    rho_nu = rho(K)
    if m in InternalAddress(K).addr
        return true
    else
        for k in 1:(m - 1)
            if mod(m, k) == 0 && rho_nu(k) > m
                return true
            end
        end
        if rho_nu(m) != Inf
            for r in 1:m
                if mod(r, m) == mod(rho_nu(m), m) && ! (m in rhosequence(K, r))
                    return true
                end
            end
        end
        return false
    end
end

#Lemma 5.4 page 43 TreesBook
function admissible(K::KneadingSequence)
    for m in 1:K.period
        if !admissible(K, m)
            return (false, m)
        end
    end
    return true
end

function admissible(intadd::InternalAddress)
    return admissible(KneadingSequence(intadd))
end

"""An internal address with aditional information in the form of angles which specify a cyclic ordering of kneading sequences"""
struct AngledInternalAddress
    addr::Vector{Int}
    angles::Vector{Rational}
end

#Lemma 11.14 TreesBook page 146
function AngledInternalAddress(theta)
    intadd = InternalAddress(KneadingSequence(theta))
    denoms = denominators(intadd)
    angles = Rational[]

    for ii in 1:(length(intadd) - 1)
        n = 0
        x = theta
        for _ in 1:(denoms[ii] - 1)
            if x <= theta
                n += 1
            end
            for _ in 1:intadd[ii]
                x = mod(2x, 1)
            end
        end
        push!(angles, n // denoms[ii])
    end

    return AngledInternalAddress(intadd.addr, angles)

end

function Base.show(io::IO, AIA::AngledInternalAddress)
    address = ""
    for ii in eachindex(AIA.addr)
        address *= repr(AIA.addr[ii])
        if ii < lastindex(AIA.addr) #this will return true if num is not the last element because addr has no repeats
            address *= "———"
            address *= repr(AIA.angles[ii])
            address *= "——>"
        end
    end
    return print(io, "Angled Internal Address" * "\n" * address)
end

function firstaddress(intadd::Vector{Int})
    d = denominators(intadd)
    angles = [1 // x for x in d]
    return AngledInternalAddress(intadd, angles)
end

#"""returns the internal address obtained by appending two times the last number of the internal address provided"""
function bifurcate(aia::AngledInternalAddress)
    intadd = copy(aia.addr)
    intadd = append!(intadd, intadd[end] * 2 // 1)
    angles = append!(copy(aia.angles), 1 // 2)
    return AngledInternalAddress(intadd, angles)
end

#TreesBook pg 145
#"""returns the denominators of the angles of any angled internal address with the given integer values"""
function denominators(S::InternalAddress)
    n = length(S) - 1
    #the last entry has no angle #page 143

    K = KneadingSequence(S)

    q = Int[]

    for k in 1:n
        r = mod1(S[k + 1], S[k])
        orb = rhosequence(K, r)
        if S[k] in orb
            qk = (S[k + 1] - r) / S[k] + 1
        else
            qk = (S[k + 1] - r) / S[k] + 2
        end
        push!(q, qk)
    end

    return q
end

function newdenominator(AIA::AngledInternalAddress, new::Int)
    K = KneadingSequence(InternalAddress(AIA.addr))
    p = n -> rhosequence(K, n)

    r = mod1(new, AIA.addr[end])
    orb = p(r)

    if AIA.addr[end] in orb
        qk = Int((new - r) / AIA.addr[end] + 1) #why is this always an integer?

    else
        qk = Int((new - r) / AIA.addr[end] + 2)

    end

    return qk
end


function numembeddings(IA::InternalAddress)
    n = 1
    for d in denominators(IA)
        n = n * totient(d) #The number of integers less than d and coprime
    end
    return n
end

numembeddings(addr::Vector{Int}) = numembeddings(InternalAddress(addr))

numembeddings(theta::Rational) = numembeddings(InternalAddress(theta))

function period(theta)
    return orbit(theta).period
end
