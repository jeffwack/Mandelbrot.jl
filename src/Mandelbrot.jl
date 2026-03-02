module Mandelbrot

export BinaryExpansion,
       Digit,
       KneadingSequence, 
       InternalAddress, 
       HubbardTree, 
       AngledInternalAddress, 
       OrientedHubbardTree,
       HyperbolicComponent,
       parameter,
       orbit

using IterTools,
      Primes

include("Sequences.jl")
include("angledoubling.jl")

include("Graphs.jl")
include("HubbardTrees.jl")

include("orienttrees.jl")
include("dynamicrays.jl")
include("embedtrees.jl")


include("spiderfuncs.jl")
include("spidermap.jl")

end
