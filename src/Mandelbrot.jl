module Mandelbrot

export AngledInternalAddress,
    OrientedHubbardTree,
    leafvertices,
    edgevertices,
    branchvertices,
    EmbeddedHubbardTree,
    parameter,
    orbit,
    characteristicset,
    characteristicorbits,
    ischaracteristic

using IterTools,
    Primes

include("Sequences.jl")
export shift, prepend

include("KneadingSequence.jl")
export BinaryExpansion, KneadingSequence

include("InternalAddress.jl")
export InternalAddress

include("Graphs.jl")
include("HubbardTrees.jl")
export HubbardTree

include("orienttrees.jl")
include("dynamicrays.jl")
include("embedtrees.jl")


include("spiderfuncs.jl")
include("spidermap.jl")

end
