#=
This file defines 'sequences' which represent infinite, eventually periodic indexed collections of items.
=#

struct Sequence{T}
    items::Vector{T}
    preperiod::Int

    #this inner constructor ensures that all sequences are in reduced form
    function Sequence{T}(items::Vector{T},preperiod::Int) where T
        #first check that the periodic part is prime
        repetend = items[(preperiod+1):end]
        k = length(repetend)
    
        if length(repetend) > 1
            for d in divisors(k) #divisors() is defined in Primes.jl
                chunks = collect.(partition(repetend,d))
                if allequal(chunks)
                    repetend = chunks[1]
                    k = length(repetend)
                    break
                end
            end
        end
    
        if preperiod != 0
            preperiod = copy(items[1:preperiod])
            while !isempty(preperiod) && repetend[end] == preperiod[end]
                pop!(preperiod)
                circshift!(repetend,1)
            end
            return new{T}(append!(copy(preperiod),repetend),length(preperiod)) 
        else
            return new{T}(repetend,0)
        end
    
    end
end

function Base.getproperty(S::Sequence,sym::Symbol)
    if sym === :period
        return length(S.items) - S.preperiod
    else
        return getfield(S,sym)
    end
end

function Sequence(str::String,preperiod::Int)
    return Sequence{Char}(Vector{Char}(str),preperiod)
end

import Base.==
function ==(x::Sequence,y::Sequence)
    return x.items==y.items && x.preperiod==y.preperiod
end

#allows for accessing elements of a sequence with array syntax. 
#Should negative indexing be allowed for strictly periodic sequences?
function Base.getindex(S::Sequence, ii::Int)
    if ii <= S.preperiod
        return S.items[ii]
    else
        k = length(S.items) - S.preperiod
        return S.items[mod1(ii-S.preperiod,k)]
    end
end

function Base.getindex(S::Sequence, I::UnitRange)
    return [S[ii] for ii in I]
end

#Hashing is required to use sequences as dictionary keys
function Base.hash(S::Sequence,h::UInt)
    k = hash(S.preperiod,foldr(hash,S.items; init = UInt(0)))
    return hash(h,hash(:Sequence,k))
end

#The vertical bars play the role of the overbar indicating the periodic part of a decimal expansion
#Printing an overbar is possible but looked ugly, so I opted for these vertical bars instead.
#They evoke musical repeat symbols.
function Base.show(io::IO, K::Sequence)
    str = join([string(item) for item in K.items])
    L = K.preperiod
    if L == 0
        return print(io,"|"*str*"|")
    else
        return print(io,str[1:L]*"|"*str[L+1:end]*"|")
    end
end

function shift(seq::Sequence{T}) where T
    if seq.preperiod == 0 
        #then seq is periodic
        return Sequence{T}(circshift(copy(seq.items),-1),0)
    else
        #then the sequence is preperiodic
        return Sequence{T}(collect(Iterators.drop(seq.items,1)),seq.preperiod-1)
    end  
end

function shiftby(seq::Sequence,n::Int)
    if n<0
        error("cannot shift a sequence a negative number of times")
    elseif n==0
        return seq
    elseif n==1
        return shift(seq)
    else
        return shift(shiftby(seq,n-1))
    end
end

#This is the 'inverse' of shift, you must supply the new item which will be prepended to the sequence
function prepend(K::Sequence{T},thing) where T
    return Sequence{T}(pushfirst!(copy(K.items),thing),K.preperiod+1)
end

