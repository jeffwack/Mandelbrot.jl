module MakieExt

# Use Makie (works with any backend: GLMakie, CairoMakie, WGLMakie)
using Makie
using Mandelbrot
using ColorSchemes, Colors

__init__() = println("Mandelbrot visualization extension loaded (backend: $(Makie.current_backend()))")

# Import existing functions to extend
import Mandelbrot: treeplot, spiderplot, showspider
# Import recipe-based functions to extend  
import Mandelbrot: hubbardtreeplot, hubbardtreeplot!, mandelbrotsetplot, mandelbrotsetplot!, juliasetplot, juliasetplot!

# Include all extension files
include("showtree.jl")
include("showspider.jl") 
include("showrays.jl")
include("mandelbrotset.jl")
include("juliaset.jl")
include("interiorbinarydecomp.jl")
include("recipes.jl")

# Don't export the functions - they're already exported from the main package
# Only export the recipe types for advanced users who want to use them directly
export HubbardTreePlot, MandelbrotSetPlot, JuliaSetPlot

end
