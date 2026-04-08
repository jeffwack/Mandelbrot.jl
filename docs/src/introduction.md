# Introduction

The Mandelbrot set is the set of all complex numbers c such that the forward orbit of 0 under the function z -> z^2 + c is bounded. 
Much of the Mandelbrot set's fame comes from the ease with which one can render an interesting image using a few lines of code.

FedericoStra on Julia Discourse provided this nice script which he admitted is 'a bit golfed' 

https://discourse.julialang.org/t/seven-lines-of-julia-examples-sought/50416/10

```julia
function mandelbrot(z) w = z
    for n in 1:74
        abs2(w) < 4 ? w = w^2 + z : return n
    end; 75
end
x, y = range(-0.65, -0.45; length=1600), range(0.51, 0.71; length=1600)
heatmap(x, y, -log.(mandelbrot.(x' .+ y .* im)))
```

```@example intro
using CairoMakie, BrotViz, Mandelbrot
fig, ax, = mandelbrotsetplot(0.0+0.0im, 4.0)
fig
```

```@example intro
fig, ax, = mandelbrotsetplot(-0.5+0.5im, 0.1, max_iterations=500)
fig
```
