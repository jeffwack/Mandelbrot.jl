function mandelbrotpatch(A::Complex, B::Complex, scale::Real,size::Int)
    #we will first compute the patch at the correct scale and orientation, centered at the origin
    #we will then translate the patch to to correct location and return it

    center = 0.5*(A + B)  
    #The center of the patch

    to_side = scale*(A - B) 
    #The complex number which points from the origin to the right side of the origin-centered patch

    to_top = 1.0im*to_side
    #points from the origin to the top of the frame

    horizontal_axis = LinRange(-to_side,to_side,size)
    vertical_axis = LinRange(-to_top,to_top,size)

    origin_patch = transpose(vertical_axis) .+ horizontal_axis
    #we want a matrix whose i,jth element is H[i] + V[j]

    return origin_patch .+ center
end

function brotplot(c1,c2)

    scale = 10

    M = mandelbrotpatch(c1,c2,scale,500)
    PA = mproblem_array(M,escape(100),500)

    fig = Figure()
    ax1 = Axis(fig[1,1])
    ax2 = Axis(fig[1,2])

    colors = colorax(fig,ax2,8)

    heatmap!(ax1,mod.([x[1] for x in escapetime.(PA)],50),nan_color = RGBAf(0,0,0,1),colormap = colors)
    on(events(ax1).scroll, priority = 1) do event

        # Determine zoom factor (adjust the value for different zoom speed)
        zoom_factor = first(filter(x->x!=0,event))

        zoom_factor = zoom_factor > 0 ? sqrt(1/(zoom_factor+1)) : sqrt(-zoom_factor+1)
    
        # Adjusted xrange and yrange
        scale = scale*zoom_factor
        println(scale)
        M = mandelbrotpatch(c1,c2,scale,500)
        PA = mproblem_array(M,escape(100),500)
        empty!(ax1)
        heatmap!(ax1,mod.([x[1] for x in escapetime.(PA)],50),nan_color = RGBAf(0,0,0,1),colormap = colors)
    end

    return fig
end


function brotplot(aia::AngledInternalAddress)
    @time theta1 = first(criticalanglesof(aia))
    println(RationalAngle(theta1))
    @time theta2 = first(criticalanglesof(bifurcate(aia)))
    println(RationalAngle(theta2))

    @time c1 = parameter(RationalAngle(theta1),500)
    println(c1)
    @time c2 = parameter(RationalAngle(theta2),500)
    println(c2)

    return brotplot(c1,c2)
end

function movie(list)
    for (ii,item) in enumerate(list)
        save("frameb$ii.png",showm(item))
    end
end

