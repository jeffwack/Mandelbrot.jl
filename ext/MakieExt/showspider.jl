@recipe(SpiderPlot,S) do scene
    Theme()
end

function Makie.plot!(myplot::SpiderPlot)
    n = length(myplot.S[].legs)
    for (j ,leg) in enumerate(myplot.S[].legs)
        lines!(myplot, real(leg),imag(leg),color = get(ColorSchemes.viridis, float(j)/float(n)))
        text!(myplot, real(leg[end]),imag(leg[end]);text = "$j")
    end
    r = 6
    limits!(-r-1,r-1,-r,r)
    #why can we use the above function but cannot do other things like hidespines?
    return myplot
end


function showspider(angle::Rational,frames::Int)

    S0 = Mandelbrot.standardspider(angle)

    list = Mandelbrot.spideriterates(S0,frames)

    fig = Figure()
    ax = Axis(fig[1, 1])

    num = angle.num
    den = angle.den
    
    record(fig,"$num.$den.gif",1:frames; framerate = 3) do i
        empty!(ax)
        spiderplot!(ax,list[i])
    end 
        
end 


