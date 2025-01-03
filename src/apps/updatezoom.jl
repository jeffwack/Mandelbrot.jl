using GLMakie
#using("../mandelbrotset.jl")

fig = Figure()
ax = Makie.Axis(fig[1, 1])

noPoints = 1000

r = 2

horizontal_axis = LinRange(-r,r,noPoints)
vertical_axis =  LinRange(-r,r,noPoints)

origin_patch = transpose(vertical_axis) .+ 1.0im .*horizontal_axis
#we want a matrix whose i,jth element is H[i] + V[j]

h = abs2.(origin_patch)

heatmap!(ax,horizontal_axis,vertical_axis,h)

xlims!(ax,[-r,r])
ylims!(ax,[-r,r])

 
on(events(ax).scroll, priority = 1) do event

    rectangle = ax.finallimits[]
    xlims = (rectangle.origin[1], rectangle.origin[1] + rectangle.widths[1])
    ylims = (rectangle.origin[2], rectangle.origin[2] + rectangle.widths[2])

    xrange = (xlims[2] - xlims[1])/2
    yrange = (ylims[2] - ylims[1])/2

    # Determine zoom factor (adjust the value for different zoom speed)
    zoom_factor = first(filter(x->x!=0,event))

    zoom_factor = zoom_factor > 0 ? sqrt(1/(zoom_factor+1)) : sqrt(-zoom_factor+1)
   
    # Adjusted xrange and yrange
    adjusted_xrange = xrange * zoom_factor
    adjusted_yrange = yrange * zoom_factor

    # Calculate new limits based on mouse position ratio
    new_xlims = (-adjusted_xrange, adjusted_xrange)
    new_ylims = (-adjusted_yrange,adjusted_yrange)

    # Update limits
    ax.limits = (new_xlims..., new_ylims...)

    horizontal_axis = LinRange(-adjusted_xrange,adjusted_xrange,noPoints)
    vertical_axis =  LinRange(-adjusted_yrange,adjusted_yrange,noPoints)

    origin_patch = transpose(vertical_axis) .+ 1.0im .*horizontal_axis
    #we want a matrix whose i,jth element is H[i] + V[j]

    h = abs2.(origin_patch)
    empty!(ax)
    heatmap!(ax,horizontal_axis,vertical_axis,h)
end

fig