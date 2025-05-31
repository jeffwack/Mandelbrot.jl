@recipe(RayPlot,ExtRays) do scene 
    Theme()
end

function Makie.plot!(myplot::RayPlot)
    rays = collect(values(myplot.ExtRays[].rays))
    n = length(rays)
    for (j ,ray) in enumerate(rays)
        lines!(myplot,real(ray),imag(ray),color = get(ColorSchemes.rainbow, float(j)/float(n)))
    end
    return myplot
end


function plotrays!(ax,rays::Vector{Vector{ComplexF64}})
    n = length(rays)

    for (j ,ray) in enumerate(rays)
        lines!(ax,real(ray),imag(ray),color = get(ColorSchemes.rainbow, float(j)/float(n)))
    end

    return ax
end


function plotrays(rays::Vector{Vector{ComplexF64}})

    fig = Figure()
    ax = Axis(fig[1, 1],aspect = 1)
    r = 2
    xlims!(-r,r)
    ylims!(-r,r)

    n = length(rays)

    for (j ,ray) in enumerate(rays)
        lines!(ax,real(ray),imag(ray),color = get(ColorSchemes.cyclic_mygbm_30_95_c78_n256_s25, float(j)/float(n)))
    end

    return fig

end

function plotrays(c::Complex,angle::Rational,R::Real,res::Int,depth::Int)
    return plotrays(collect(values(dynamicrays(c::Complex,angle::Rational,R::Real,res::Int,depth::Int))))
end