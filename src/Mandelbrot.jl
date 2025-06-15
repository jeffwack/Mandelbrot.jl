module Mandelbrot

export BinaryExpansion, 
       KneadingSequence, 
       InternalAddress, 
       HubbardTree, 
       AngledInternalAddress, 
       OrientedHubbardTree, 
       parameter,
       orbit
       #treeplot,
       #spiderplot

using IterTools,
      Primes
      #ColorSchemes,
      #Colors,
      #GLMakie,

include("Sequences.jl")
include("angledoubling.jl")

include("Graphs.jl")
include("HubbardTrees.jl")

include("orienttrees.jl")
include("dynamicrays.jl")
include("embedtrees.jl")


include("spiderfuncs.jl")
include("spidermap.jl")

include("renderfractal.jl")


end
