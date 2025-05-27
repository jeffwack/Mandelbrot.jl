module Mandelbrot

export RationalAngle,
       BinaryExpansion, 
       KneadingSequence, 
       InternalAddress, 
       HubbardTree, 
       AngledInternalAddress, 
       OrientedHubbardTree, 
       parameter
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

include("interiorbinarydecomp.jl")
include("juliaset.jl")
include("lamination.jl")
include("mandelbrotset.jl")

include("spiderfuncs.jl")
include("spidermap.jl")

include("renderfractal.jl")
include("perturb.jl")

include("showrays.jl")
include("showspider.jl")
include("showtree.jl")

end
