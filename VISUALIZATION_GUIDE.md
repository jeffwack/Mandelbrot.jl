# Mandelbrot Package Visualization Guide

This guide covers the visualization capabilities of the Mandelbrot package using the new recipe-based plotting interface.

## Quick Start

```julia
using Mandelbrot
using GLMakie  # or CairoMakie, WGLMakie

# Plot a Hubbard tree
hubbardtree(1//3)

# Plot the Mandelbrot set
mandelbrotset()

# Plot a Julia set
juliaset(-0.3+0.0im, 2.0)
```

## Setup and Installation

The visualization features are implemented as a Makie extension that works with any Makie backend:

```julia
using Mandelbrot    # Load the main package
using GLMakie       # For interactive desktop visualization
# or using CairoMakie  # For high-quality static output  
# or using WGLMakie    # For web-based visualization
```

You should see a message like "Mandelbrot visualization extension loaded (backend: GLMakie.Backend)" when the extension activates.

## Backend Compatibility

The recipes work with all Makie backends:

| Backend | Use Case | Interactive | Best For |
|---------|----------|-------------|----------|
| **GLMakie** | Desktop apps | ✅ Full | Real-time exploration, large datasets |
| **CairoMakie** | Publications | ❌ Static | High-quality PDFs, SVGs, print |
| **WGLMakie** | Web display | ✅ Full | Jupyter notebooks, web apps |

Simply change which backend you load - all recipes work identically!

## Hubbard Tree Plotting

### Basic Usage

```julia
# Plot embedded in Julia set (default)
hubbardtree(1//3)

# Plot as dendrogram
hubbardtree(1//3, style=:dendrogram)
```

### Customization Options

```julia
hubbardtree(1//7, 
    style = :embedded,           # :embedded or :dendrogram
    show_rays = true,            # Show external rays
    show_critical_orbit = true,  # Show Julia set background
    node_size = 15,              # Size of tree nodes
    ray_colormap = :viridis,     # Ray color scheme
    limits = (-1.5, 1.5, -1.5, 1.5)  # Plot bounds
)
```

### Available Styles

- **`:embedded`**: Shows the tree embedded in its Julia set with external rays
- **`:dendrogram`**: Shows the tree as a hierarchical diagram

## Mandelbrot Set Plotting

### Basic Usage

```julia
# Standard view
mandelbrotset()

# Custom center and zoom
mandelbrotset(0.0+0.0im, 4.0)

# Zoomed-in detail
mandelbrotset(-0.5+0.5im, 0.1, max_iterations=500)
```

### Customization Options

```julia
mandelbrotset(-0.7+0.0im, 1.0,
    resolution = (1500, 1500),    # Image resolution
    max_iterations = 200,         # Escape-time iterations
    escape_radius = 2.0,          # Escape threshold
    colormap = :hot,              # Color scheme
    color_mode = :escape_time,    # :escape_time, :modulus, or :binary
    modulus_period = 20           # For modulus coloring
)
```

### Color Modes

- **`:escape_time`**: Standard escape-time coloring
- **`:modulus`**: Modulus-based coloring with periodic patterns
- **`:binary`**: Binary (inside/outside) coloring

## Julia Set Plotting

### Basic Usage

```julia
# From complex parameter
juliaset(-0.3+0.0im, 2.0)

# From external angle (uses spider algorithm)
juliaset(1//3, 2.0)
```

### Customization Options

```julia
juliaset(-0.7269+0.1889im, 1.5,
    resolution = (800, 800),           # Image resolution  
    max_iterations = 150,              # Escape iterations
    escape_threshold = 1e4,            # Escape threshold
    colormap = :plasma,                # Color scheme
    binary_decomposition = true        # Use binary coloring
)
```

### Binary Decomposition

Binary decomposition creates striking black-and-white patterns based on the argument of the final iterate:

```julia
juliaset(-0.3+0.0im, 2.0, binary_decomposition=true, colormap=:grayC)
```

## Advanced Usage

### Plotting into Existing Axes

```julia
fig = Figure()
ax1 = Axis(fig[1, 1], title="Hubbard Tree")
ax2 = Axis(fig[1, 2], title="Julia Set")

hubbardtree!(ax1, 1//3, style=:dendrogram)
juliaset!(ax2, -0.3+0.0im, 2.0)

fig
```

### Combining Multiple Plots

```julia
fig = Figure(resolution=(1200, 400))

# Mandelbrot set overview
mandelbrotset!(Axis(fig[1, 1], title="Mandelbrot Set"), 
               0.0+0.0im, 4.0, resolution=(400, 400))

# Detailed zoom
mandelbrotset!(Axis(fig[1, 2], title="Detail"), 
               -0.5+0.5im, 0.1, max_iterations=300)

# Corresponding Julia set
juliaset!(Axis(fig[1, 3], title="Julia Set"), 
          -0.5+0.5im, 2.0)

fig
```

### Interactive Exploration

Using Observables for dynamic parameter exploration:

```julia
using GLMakie

fig = Figure()
ax = Axis(fig[1, 1])

# Interactive parameter
c_slider = Slider(fig[2, 1], range=-1:0.01:1, startvalue=0.0)
c = lift(x -> x + 0.0im, c_slider.value)

# Reactive Julia set plot
juliaset!(ax, c, 2.0, max_iterations=100)

fig
```

## Performance Tips

### For High-Resolution Images

```julia
# Use lower iteration counts for initial exploration
mandelbrotset(resolution=(2000, 2000), max_iterations=100)

# Increase iterations for final high-quality renders
mandelbrotset(resolution=(2000, 2000), max_iterations=1000)
```

### For Real-Time Interaction

```julia
# Use moderate resolution for smooth interaction
juliaset(parameter, 2.0, resolution=(500, 500), max_iterations=50)
```

## Color Schemes

The package supports all ColorSchemes.jl color schemes:

```julia
mandelbrotset(colormap=:hot)        # Heat colors
mandelbrotset(colormap=:viridis)    # Perceptually uniform
mandelbrotset(colormap=:plasma)     # Purple-pink-yellow
mandelbrotset(colormap=:PRGn_9)     # Purple-green diverging
```

For Julia sets with binary decomposition:
```julia
juliaset(param, 2.0, binary_decomposition=true, colormap=:grayC)
```

## Recipe Types

For advanced users, the underlying recipe types are also exported:

- `HubbardTreePlot`
- `MandelbrotSetPlot` 
- `JuliaSetPlot`

These can be used directly with the Makie plotting system for maximum customization.

## Migration from Old Interface

If you have existing code using the old plotting functions, here's how to migrate:

```julia
# Old way
treeplot(HyperbolicComponent(1//3))

# New way
hubbardtree(1//3)

# Old way  
showmandelbrot((A, B), scale)

# New way
center = (A + B) / 2
zoom = 2 * abs(A - B) * scale
mandelbrotset(center, zoom)
```

## Troubleshooting

### Extension Not Loading

If you don't see the "Mandelbrot visualization extension loaded" message:

1. Make sure you've loaded a Makie backend: `using GLMakie` (or CairoMakie, WGLMakie)
2. Restart Julia and try again  
3. Check that your chosen Makie backend is properly installed
4. Ensure you have Julia 1.9+ (required for package extensions)

### Performance Issues

For slow rendering:

1. Reduce `resolution` parameter
2. Lower `max_iterations`
3. Use GLMakie for interactive work, CairoMakie for high-quality output

### Memory Issues

For large images:

1. Process in smaller chunks
2. Use `CairoMakie` which is more memory-efficient for static images
3. Consider using `WGLMakie` for web-based visualization

## Examples Gallery

### Classic Mandelbrot Views

```julia
# The full set
mandelbrotset()

# Seahorse valley
mandelbrotset(-0.75+0.1im, 0.1)

# Elephant valley  
mandelbrotset(0.25+0.0im, 0.01)

# Lightning
mandelbrotset(-1.775+0.0im, 0.01)
```

### Interesting Julia Sets

```julia
# Rabbit Julia set
juliaset(-0.123+0.745im, 2.0)

# Airplane Julia set
juliaset(-1.25+0.0im, 2.0)

# Dendrite Julia set
juliaset(-0.75+0.11im, 2.0)
```

### Hubbard Trees

```julia
# Period-3 component
hubbardtree(1//7)

# Period-4 component  
hubbardtree(1//15)

# Higher period
hubbardtree(3//31)
```