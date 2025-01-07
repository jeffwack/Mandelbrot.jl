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

function showmandelbrot((A, B), scale::Real)
    M = mandelbrotpatch(A,B,scale)
    PA = mproblem_array(M,escape(100),100)
    pic = [x[1] for x in escapetime.(PA)]
    return heatmap(pic,nan_color = RGBAf(0,0,0,1),colormap = :PRGn_9)
end

function brotplot(c1,c2)

    scale = 10

    M = mandelbrotpatch(c1,c2,scale,500)
    PA = mproblem_array(M,escape(100),500)

    fig = Figure()
    ax = Axis(fig[1,1])
    heatmap!(ax,mod.([x[1] for x in escapetime.(PA)],50),nan_color = RGBAf(0,0,0,1),colormap = :Set3_12)
    on(events(ax).scroll, priority = 1) do event

        # Determine zoom factor (adjust the value for different zoom speed)
        zoom_factor = first(filter(x->x!=0,event))

        zoom_factor = zoom_factor > 0 ? sqrt(1/(zoom_factor+1)) : sqrt(-zoom_factor+1)
    
        # Adjusted xrange and yrange
        scale = scale*zoom_factor
        println(scale)
        M = mandelbrotpatch(c1,c2,scale,500)
        PA = mproblem_array(M,escape(100),500)
        empty!(ax)
        heatmap!(ax,mod.([x[1] for x in escapetime.(PA)],50),nan_color = RGBAf(0,0,0,1),colormap = :Set3_12)
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

function overlay(maxiter::Int)
    M = mandelbrotpatch(0+0im,-2+0im,0.2)

    MA = mproblem_array(M,escape(100),maxiter)
    LA = lproblem_array(M,escape(10000),maxiter)

    EMA = escapetime.(MA)
    ELA = escapetime.(LA)

    CEMA = zeros(size(EMA))

    for ii in eachindex(EMA)
        if isnan(EMA[ii][1])
            CEMA[ii] = 1
        end
    end

    CELA = zeros(size(ELA))

    for ii in eachindex(ELA)
        if isnan(ELA[ii][1])
            CELA[ii] = 1
        end
    end

    fig = Figure()
    scene = Scene(camera=campixel!, resolution=(1000,1000))
    ax = Axis(scene,aspect = 1)

    #heatmap!(scene,CEMA, colormap = [RGBAf(c.r,c.g,c.b,0.5) for c in to_colormap(:reds)] )
    heatmap!(scene,CELA,colormap = [RGBAf(c.r,c.g,c.b,0.5) for c in to_colormap(:blues)])

    return scene

end