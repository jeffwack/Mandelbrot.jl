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