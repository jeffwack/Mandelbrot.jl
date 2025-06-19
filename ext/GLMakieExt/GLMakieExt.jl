module GLMakieExt

using GLMakie
using Mandelbrot
using ColorSchemes

__init__() = println("Howdy")


import Mandelbrot: treeplot, spiderplot

include("showtree.jl")
include("showspider.jl")




end
