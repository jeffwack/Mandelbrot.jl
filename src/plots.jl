function spiderplot end

function treeplot end

# Recipe-based plotting functions (implemented by MakieExt extension)

"""
    hubbardtreeplot(angle::Rational; kwargs...)

Plot a Hubbard tree for the given external angle. Requires GLMakie.

# Examples
```julia
using GLMakie
hubbardtreeplot(1//3)  # Embedded in Julia set
hubbardtreeplot(1//7, style=:dendrogram)  # As dendrogram
```

# Keyword Arguments
- `style = :embedded`: Plot style (`:embedded` or `:dendrogram`)
- `show_rays = true`: Show external rays
- `show_critical_orbit = true`: Show Julia set background
- `node_size = 10`: Size of tree nodes
- See `HubbardTreePlot` documentation for full list
"""
function hubbardtreeplot(args...; kwargs...)
    error("Hubbard tree plotting requires a Makie backend. Please run:\n" *
          "  using GLMakie\n" *
          "Then try: hubbardtreeplot(1//3)")
end

"""
    hubbardtreeplot!(ax, angle::Rational; kwargs...)

Plot a Hubbard tree into an existing axis. Requires a Makie backend.
"""
function hubbardtreeplot!(args...; kwargs...)
    error("Hubbard tree plotting requires a Makie backend. Please load GLMakie first.")
end

"""
    mandelbrotsetplot(center::Complex, zoom::Real; kwargs...)

Plot the Mandelbrot set. Requires a Makie backend.

# Examples
```julia
using GLMakie
mandelbrotsetplot(0+0im, 4.0)  # Standard view
mandelbrotsetplot(-0.5+0.5im, 0.1, max_iterations=500)  # Zoomed detail
```

# Keyword Arguments
- `resolution = (1000, 1000)`: Image resolution
- `max_iterations = 100`: Maximum escape-time iterations
- `colormap = :PRGn_9`: Color scheme
- See `MandelbrotSetPlot` documentation for full list
"""
function mandelbrotsetplot(args...; kwargs...)
    error("Mandelbrot set plotting requires GLMakie. Please run:\n" *
          "  using GLMakie\n" *
          "Then try: mandelbrotsetplot(0+0im, 4.0)")
end

"""
    mandelbrotsetplot!(ax, center::Complex, zoom::Real; kwargs...)

Plot the Mandelbrot set into an existing axis. Requires a Makie backend.
"""
function mandelbrotsetplot!(args...; kwargs...)
    error("Mandelbrot set plotting requires a Makie backend. Please load GLMakie.")
end

"""
    juliasetplot(parameter::Complex, bounds::Real; kwargs...)

Plot a Julia set. Requires GLMakie.

# Examples
```julia
using GLMakie
juliasetplot(-0.3+0.0im, 2.0)  # Standard Julia set
juliasetplot(-0.7269+0.1889im, 1.5, binary_decomposition=true)  # Binary coloring
```

# Keyword Arguments
- `resolution = (500, 500)`: Image resolution
- `max_iterations = 100`: Maximum iterations
- `binary_decomposition = false`: Use binary coloring
- See `JuliaSetPlot` documentation for full list
"""
function juliasetplot(args...; kwargs...)
    error("Julia set plotting requires GLMakie. Please run:\n" *
          "  using GLMakie\n" *
          "Then try: juliasetplot(-0.3+0.0im, 2.0)")
end

"""
    juliasetplot!(ax, parameter::Complex, bounds::Real; kwargs...)

Plot a Julia set into an existing axis. Requires a Makie backend.
"""
function juliasetplot!(args...; kwargs...)
    error("Julia set plotting requires a Makie backend. Please load GLMakie.")
end
