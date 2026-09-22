# Introduction

The Mandelbrot set is the set of all complex numbers c such that the forward orbit of 0 under the function z -> z^2 + c is bounded. 
Much of the Mandelbrot set's fame comes from the ease with which one can render an interesting image using a few lines of code.

FedericoStra on Julia Discourse provided [this nice script](https://discourse.julialang.org/t/seven-lines-of-julia-examples-sought/50416/10
) which he describes as 'a bit golfed.' 


```@example
using CairoMakie
function mandelbrot(z) w = z
    for n in 1:74
        abs2(w) < 4 ? w = w^2 + z : return n
    end; 75
end
x, y = range(-0.65, -0.45; length=1600), range(0.51, 0.71; length=1600)
heatmap(x, y, -log.(mandelbrot.(x' .+ y .* im)))
```

In these few lines of code, there are only a few pieces of data:
- The number of iterations, 75
- The function w = w^2 + z 
- The condition `abs2(w) < 4` 
- The evenly spaced 1600x1600 grid with (-0.65,0.51) and (-0.45,0.71) as corners

Where does the picture come from? 

