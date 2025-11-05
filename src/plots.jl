function spiderplot end

function treeplot end

function showspider end

# Recipe-based plotting functions (implemented by MakieExt extension)

"""
    hubbardtreeplot(angle::Rational; kwargs...)

Plot a Hubbard tree for the given external angle. Requires a Makie backend (GLMakie, CairoMakie, or WGLMakie).

# Examples
```julia
using Mandelbrot, GLMakie

# Basic embedded plot with default limits
hubbardtreeplot(1//3)

# Dendrogram style
hubbardtreeplot(1//7, style=:dendrogram)

# Custom limits and options
hubbardtreeplot(3//5, limits=(-1.5, 1.5, -1.0, 1.0), show_rays=false)

# Larger nodes and different colors
hubbardtreeplot(1//3, node_size=15, show_critical_orbit=false)
```

# Keyword Arguments
- `style = :embedded`: Plot style (`:embedded` shows tree in Julia set, `:dendrogram` shows abstract tree)
- `show_rays = true`: Show external rays connecting to hyperbolic component
- `show_critical_orbit = true`: Show Julia set background points
- `node_size = 10`: Size of tree nodes in plot
- `limits = (-2, 2, -2, 2)`: Plot limits as (xmin, xmax, ymin, ymax)
- `ray_colormap = :rainbow`: Colormap for external rays
- `julia_resolution = 20`: Resolution for Julia set background computation

See `HubbardTreePlot` recipe documentation for complete list of attributes.
"""
function hubbardtreeplot end

"""
    hubbardtreeplot!(ax, angle::Rational; kwargs...)

Plot a Hubbard tree into an existing axis. Requires a Makie backend.
"""
function hubbardtreeplot! end

"""
    mandelbrotsetplot(center::Complex, zoom::Real; kwargs...)

Plot the Mandelbrot set. Requires a Makie backend (GLMakie, CairoMakie, or WGLMakie).

# Examples
```julia
using Mandelbrot, GLMakie

# Standard view
mandelbrotsetplot(0+0im, 4.0)

# Zoomed detail with more iterations
mandelbrotsetplot(-0.5+0.5im, 0.1, max_iterations=500)

# High resolution with different colormap
mandelbrotsetplot(0+0im, 4.0, resolution=(2000, 2000), colormap=:hot)

# Different coloring modes
mandelbrotsetplot(0+0im, 4.0, color_mode=:binary, interior_color=:white)
```

# Keyword Arguments
- `resolution = (1000, 1000)`: Image resolution as (width, height)
- `max_iterations = 100`: Maximum escape-time iterations
- `escape_radius = 2.0`: Escape radius threshold
- `colormap = :PRGn_9`: Color scheme for visualization
- `interior_color = :black`: Color for points in the Mandelbrot set
- `color_mode = :escape_time`: Coloring method (`:escape_time`, `:modulus`, `:binary`)
- `modulus_period = 50`: Period for modulus coloring

See `MandelbrotSetPlot` recipe documentation for complete list of attributes.
"""
function mandelbrotsetplot end

"""
    mandelbrotsetplot!(ax, center::Complex, zoom::Real; kwargs...)

Plot the Mandelbrot set into an existing axis. Requires a Makie backend.
"""
function mandelbrotsetplot! end

"""
    juliasetplot(parameter::Complex, bounds::Real; kwargs...)
    juliasetplot(angle::Rational, bounds::Real; kwargs...)

Plot a Julia set. Requires a Makie backend (GLMakie, CairoMakie, or WGLMakie).

# Examples
```julia
using Mandelbrot, GLMakie

# Julia set for specific parameter
juliasetplot(-0.3+0.0im, 2.0)  

# Julia set with binary decomposition coloring
juliasetplot(-0.7269+0.1889im, 1.5, binary_decomposition=true)

# Julia set from external angle (convenience method)
juliasetplot(1//3, 2.0)  # Uses spider algorithm to find parameter

# High resolution with custom colormap
juliasetplot(-0.3+0.0im, 2.0, resolution=(1000, 1000), colormap=:viridis)
```

# Keyword Arguments
- `resolution = (500, 500)`: Image resolution as (width, height)
- `max_iterations = 100`: Maximum iterations for escape-time
- `escape_threshold = 1e4`: Escape threshold for convergence test
- `colormap = :grayC`: Colormap for visualization
- `binary_decomposition = false`: Use binary decomposition coloring
- `interior_color = RGBf(172/255, 88/255, 214/255)`: Color for interior points

See `JuliaSetPlot` recipe documentation for complete list of attributes.
"""
function juliasetplot end

"""
    juliasetplot!(ax, parameter::Complex, bounds::Real; kwargs...)

Plot a Julia set into an existing axis. Requires a Makie backend.
"""
function juliasetplot! end
