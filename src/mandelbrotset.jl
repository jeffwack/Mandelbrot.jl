function mframe()
end

function brotplot(c1,c2)

    scale = 10
    center = (c1+c2)/2
    diff = abs(c1-c2)
    N = 500

    fig = Figure()
    ax1 = Axis(fig[1,1])
    ax2 = Axis(fig[1,2])

    colors = colorax(fig,ax2,8)

    on(events(ax1).scroll, priority = 1) do event

        # Determine zoom factor (adjust the value for different zoom speed)
        zoom_factor = first(filter(x->x!=0,event))

        zoom_factor = zoom_factor > 0 ? sqrt(1/(zoom_factor+1)) : sqrt(-zoom_factor+1)
    
        # Adjusted xrange and yrange
        scale = scale*zoom_factor
        println(scale)

        right_center_displacement = scale*diff

        top_center_displacement = right_center_displacement
        #points from the origin to the top of the frame
    
        horizontal_axis = LinRange(-right_center_displacement,right_center_displacement,N)
        vertical_axis = LinRange(-top_center_displacement,top_center_displacement,N)
    
        origin_patch = transpose(-1.0im*vertical_axis) .+ horizontal_axis

        M = origin_patch .+ center

        PA = mproblem_array(M,escape(100),500)
       
        pic = mod.([x[1] for x in escapetime.(PA)],50)
        ax1.limits = (horizontal_axis[1].+real(center), horizontal_axis[end].+real(center),vertical_axis[1].+imag(center),vertical_axis[end].+imag(center))
        heatmap!(ax1,horizontal_axis.+real(center),vertical_axis.+imag(center),pic,nan_color = RGBAf(0,0,0,1),colormap = colors)

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

