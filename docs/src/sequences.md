Some examples of sequences are:
* the forward orbit of an angle
* the binary decomposition of an angle
* the kneading sequence of an angle
* the forward orbit of an external dynamic ray

An infinite sequence which is eventually periodic can be represented by a finite string and a description of how it repeats. A familiar implementation of this is the use of the [overline](https://en.wikipedia.org/wiki/Vinculum_(symbol)) for repeating decimal expansions.

The implementation used here is 
`struct Sequence
    items::Vector
    preperiod::Int
end`

a common pattern is 
2,3,4,...,preperiod+1
this can be constructed by the function "goesto"