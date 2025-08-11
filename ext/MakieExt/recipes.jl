# Makie Recipes for Mandelbrot Package Visualizations
# This file implements user-friendly recipe-based plotting functions
# Works with any Makie backend: GLMakie, CairoMakie, WGLMakie

# ============================================================================
# HubbardTreePlot Recipe
# ============================================================================

"""
    HubbardTreePlot(angle::Rational)

Recipe for plotting Hubbard trees associated with hyperbolic components.

## Attributes
- `style::Symbol = :embedded`: Plotting style, either `:embedded` (in Julia set) or `:dendrogram`
- `show_rays::Bool = true`: Whether to show external rays
- `show_critical_orbit::Bool = true`: Whether to show critical orbit points
- `node_size::Real = 10`: Size of tree nodes
- `ray_colormap::Symbol = :rainbow`: Colormap for external rays
- `node_colormap::Vector = [:red, :blue, :green, :orange, :black, :turquoise, :orangered2]`: Colors for different node types
- `limits::Tuple = (-2, 2, -2, 2)`: Plot limits as (xmin, xmax, ymin, ymax)
- `julia_resolution::Int = 20`: Resolution for Julia set background points

## Examples
```julia
using Mandelbrot, GLMakie  # or CairoMakie, WGLMakie
hubbardtreeplot(1//3)  # Embedded in Julia set
hubbardtreeplot(1//7, style=:dendrogram)  # As dendrogram
hubbardtreeplot(3//5, limits=(-1.5, 1.5, -1.0, 1.0))  # Custom limits
```
"""
@recipe(HubbardTreePlot, angle) do scene
    Attributes(
        style = :embedded,
        show_rays = true,
        show_critical_orbit = true,
        node_size = 10,
        ray_colormap = :rainbow,
        node_colormap = [:red, :blue, :green, :orange, :black, :turquoise, :orangered2],
        limits = (-2, 2, -2, 2),
        julia_resolution = 20
    )
end

function Makie.plot!(plot::HubbardTreePlot)
    angle = plot[1][]
    
    if plot[:style][] == :embedded
        plot_embedded_tree!(plot, angle)
    elseif plot[:style][] == :dendrogram
        plot_dendrogram_tree!(plot, angle)
    else
        error("Unknown style: $(plot[:style][]). Use :embedded or :dendrogram")
    end
    
    return plot
end

function plot_embedded_tree!(plot, angle::Rational)
    HC = HyperbolicComponent(angle)
    htree = HC.htree
    (EdgeList, Nodes) = Mandelbrot.adjlist(htree.adj)
    criticalorbit = orbit(htree.criticalpoint)
    
    # Prepare node colors and labels
    nodecolors = get_node_colors(HC, Nodes, plot[:node_colormap][])
    labels = get_node_labels(Nodes, criticalorbit)
    
    # Plot Julia set background if requested
    if plot[:show_critical_orbit][]
        julia = Mandelbrot.inverseiterate(HC.parameter, plot[:julia_resolution][])
        scatter!(plot, real(julia), imag(julia), markersize=1, color=:black)
    end
    
    # Plot tree edges
    plot_tree_edges!(plot, EdgeList, Nodes, HC, nodecolors)
    
    # Plot external rays if requested
    if plot[:show_rays][]
        plot_external_rays!(plot, HC, plot[:ray_colormap][])
    end
    
    # Plot tree nodes
    zvalues = [HC.vertices[node] for node in Nodes]
    pos = Point.(real.(zvalues), imag.(zvalues))
    scatter!(plot, pos, color=nodecolors, markersize=plot[:node_size][])
    
    # Add node labels
    tex = [label[2] for label in labels]
    text!(plot, pos, text=tex)
    
    # Set axis limits
    lims = plot[:limits][]
    limits!(lims[1], lims[2], lims[3], lims[4])
end

function plot_dendrogram_tree!(plot, angle::Rational)
    H = HubbardTree(KneadingSequence(angle))
    (E, nodes) = Mandelbrot.adjlist(H.adj)
    root = H.criticalpoint
    
    criticalorbit = orbit(root)
    labels = []
    
    for node in nodes
        idx = findall(x->x==node, criticalorbit.items)
        if isempty(idx)
            push!(labels, Pair(node, repr("text/plain", node)))
        else
            push!(labels, Pair(node, string(idx[1] - criticalorbit.preperiod - 1)))
        end
    end
    
    rootindex = findall(x->x==root, nodes)[1]
    pos = generationposition(E, rootindex)
    
    # Plot tree edges
    for (ii, p) in enumerate(E)
        for n in p
            lines!(plot, [pos[ii], pos[n]], linewidth=1)
        end
    end
    
    # Plot nodes
    scatter!(plot, pos, markersize=plot[:node_size][])
    
    # Add labels
    tex = [label[2] for label in labels]
    text!(plot, pos, text=tex)
end

# Helper functions
function get_node_colors(HC, Nodes, colormap)
    nodecolors = String[]
    for node in Nodes
        firstchar = node.items[1]
        if firstchar == Mandelbrot.KneadingSymbol('*')
            push!(nodecolors, "black")
        elseif firstchar == Mandelbrot.KneadingSymbol('A')
            if HC.onezero[node] == Mandelbrot.Digit{2}(0)
                push!(nodecolors, "blue")
            elseif HC.onezero[node] === nothing
                push!(nodecolors, "turquoise")
            elseif HC.onezero[node] == Mandelbrot.Digit{2}(1)
                push!(nodecolors, "green")
            end
        elseif firstchar == Mandelbrot.KneadingSymbol('B')
            if HC.onezero[node] == Mandelbrot.Digit{2}(0)
                push!(nodecolors, "red")
            elseif HC.onezero[node] === nothing
                push!(nodecolors, "orangered2")
            elseif HC.onezero[node] == Mandelbrot.Digit{2}(1)
                push!(nodecolors, "orange")
            end
        end
    end
    return nodecolors
end

function get_node_labels(Nodes, criticalorbit)
    labels = []
    for node in Nodes
        idx = findall(x->x==node, criticalorbit.items)
        if isempty(idx)
            push!(labels, Pair(node, repr("text/plain", node)))
        else
            push!(labels, Pair(node, string(idx[1] - criticalorbit.preperiod - 1)))
        end
    end
    return labels
end

function plot_tree_edges!(plot, EdgeList, Nodes, HC, nodecolors)
    colorsforinterior = ["red", "blue", "green", "orange"]
    
    for (ii, p) in enumerate(EdgeList)
        for n in p
            cmplxedge = HC.edges[Set([Nodes[ii], Nodes[n]])][2]
            realedge = Point.(real.(cmplxedge), imag.(cmplxedge))
            
            # Determine edge color
            col = "black"  # default
            if nodecolors[ii] in colorsforinterior
                col = nodecolors[ii]
            elseif nodecolors[n] in colorsforinterior
                col = nodecolors[n]
            elseif nodecolors[ii] !== "black"
                col = nodecolors[ii]
            elseif nodecolors[n] !== "black"
                col = nodecolors[n]
            end
            
            lines!(plot, realedge, color=col, linewidth=1, transparency=true, overdraw=true)
        end
    end
end

function plot_external_rays!(plot, HC, colormap)
    rays = collect(values(HC.rays))
    n = length(rays)
    for (j, ray) in enumerate(rays)
        lines!(plot, real(ray), imag(ray), 
               color=get(ColorSchemes.rainbow, float(j)/float(n)))
    end
end

# ============================================================================
# MandelbrotSetPlot Recipe
# ============================================================================

"""
    MandelbrotSetPlot(center, zoom)

Recipe for plotting the Mandelbrot set.

## Attributes
- `resolution::Tuple{Int,Int} = (1000, 1000)`: Image resolution
- `max_iterations::Int = 100`: Maximum escape-time iterations
- `escape_radius::Real = 2.0`: Escape radius threshold
- `colormap::Symbol = :PRGn_9`: Colormap for visualization
- `interior_color = :black`: Color for points in the Mandelbrot set
- `color_mode::Symbol = :escape_time`: Coloring method (`:escape_time`, `:modulus`, `:binary`)
- `modulus_period::Int = 50`: Period for modulus coloring

## Examples
```julia
using Mandelbrot, GLMakie  # or CairoMakie, WGLMakie
mandelbrotset(0+0im, 2.0)  # Standard view
mandelbrotset(-0.5+0.5im, 0.1, max_iterations=500)  # Zoomed detail
```
"""
@recipe(MandelbrotSetPlot, center, zoom) do scene
    Attributes(
        resolution = (1000, 1000),
        max_iterations = 100,
        escape_radius = 2.0,
        colormap = :PRGn_9,
        interior_color = :black,
        color_mode = :escape_time,
        modulus_period = 50
    )
end

function Makie.plot!(plot::MandelbrotSetPlot)
    center = plot[1][]
    zoom = plot[2][]
    
    # Create coordinate patch
    patch = create_mandelbrot_patch(
        center, 
        zoom, 
        plot[:resolution][]
    )
    
    # Compute escape times
    problem_array = Mandelbrot.mproblem_array(
        patch, 
        Mandelbrot.escape(plot[:escape_radius][]), 
        plot[:max_iterations][]
    )
    
    escape_data = Mandelbrot.escapetime.(problem_array)
    
    # Apply coloring based on mode
    if plot[:color_mode][] == :escape_time
        pic = [x[1] for x in escape_data]
    elseif plot[:color_mode][] == :modulus
        pic = mod.([x[1] for x in escape_data], plot[:modulus_period][])
    elseif plot[:color_mode][] == :binary
        pic = [isnan(x[1]) ? 0 : 1 for x in escape_data]
    else
        error("Unknown color_mode: $(plot[:color_mode][])")
    end
    
    # Create the heatmap
    heatmap!(plot, pic, 
             colormap = plot[:colormap][], 
             nan_color = plot[:interior_color][])
    
    return plot
end

function create_mandelbrot_patch(center::Complex, zoom::Real, resolution::Tuple{Int,Int})
    width, height = resolution
    
    # Calculate bounds
    aspect_ratio = height / width
    half_width = zoom / 2
    half_height = half_width * aspect_ratio
    
    # Create coordinate grid
    x_range = LinRange(real(center) - half_width, real(center) + half_width, width)
    y_range = LinRange(imag(center) - half_height, imag(center) + half_height, height)
    
    # Create complex coordinate matrix
    return [x + y*im for y in reverse(y_range), x in x_range]
end

# ============================================================================
# JuliaSetPlot Recipe  
# ============================================================================

"""
    JuliaSetPlot(parameter, bounds)

Recipe for plotting Julia sets.

## Attributes
- `resolution::Tuple{Int,Int} = (500, 500)`: Image resolution
- `max_iterations::Int = 100`: Maximum iterations for escape-time
- `escape_threshold::Real = 1e4`: Escape threshold for convergence test
- `colormap::Symbol = :grayC`: Colormap for visualization
- `binary_decomposition::Bool = false`: Use binary decomposition coloring
- `interior_color = RGBf(172/255, 88/255, 214/255)`: Color for interior points

## Examples
```julia
using Mandelbrot, GLMakie  # or CairoMakie, WGLMakie
juliaset(-0.3+0.0im, 2.0)  # Julia set for c = -0.3
juliaset(-0.7269+0.1889im, 1.5, binary_decomposition=true)  # Binary coloring
```
"""
@recipe(JuliaSetPlot, parameter, bounds) do scene
    Attributes(
        resolution = (500, 500),
        max_iterations = 100,
        escape_threshold = 1e4,
        colormap = :grayC,
        binary_decomposition = false,
        interior_color = RGBf(172/255, 88/255, 214/255)
    )
end

function Makie.plot!(plot::JuliaSetPlot)
    parameter = plot[1][]
    bounds = plot[2][]
    
    # Create Julia set patch
    patch = Mandelbrot.julia_patch(0.0+0.0im, bounds+0.0im)
    
    # Define the function
    f(z) = z*z + parameter
    
    if plot[:binary_decomposition][]
        # Binary decomposition version
        epsilon = 1.0 / plot[:escape_threshold][]
        problem_array = Mandelbrot.jproblem_array(patch, f, Mandelbrot.escape(1/epsilon), plot[:max_iterations][])
        escape_data = Mandelbrot.escapetime.(problem_array)
        pic = assignbinary.(escape_data)
    else
        # Standard escape-time version
        problem_array = Mandelbrot.jproblem_array(patch, f, Mandelbrot.escapeorconverge(plot[:escape_threshold][]), plot[:max_iterations][])
        escape_data = Mandelbrot.escapetime.(problem_array)
        pic = [x[1] for x in escape_data]
    end
    
    # Create the heatmap
    heatmap!(plot, pic, 
             colormap = plot[:colormap][], 
             nan_color = plot[:interior_color][])
    
    return plot
end

# Note: assignbinary function is already defined in juliaset.jl

# ============================================================================
# Convenience functions that call the recipes
# ============================================================================

# The @recipe macro automatically creates both hubbardtree and hubbardtree! functions
# Same for mandelbrotset/mandelbrotset! and juliaset/juliaset!
# No need to define them manually

# ============================================================================
# Additional convenience methods
# ============================================================================

"""
    juliasetplot(angle::Rational, bounds::Real; kwargs...)

Plot the Julia set for the parameter corresponding to the given external angle.
"""
function juliasetplot(angle::Rational, bounds::Real; kwargs...)
    parameter = Mandelbrot.parameter(angle, 500)  # Use spider algorithm to find parameter
    juliasetplot(parameter, bounds; kwargs...)
end

# Note: mandelbrotsetplot() convenience method removed to avoid method overwriting
# Use: mandelbrotsetplot(0.0+0.0im, 4.0) for standard view
