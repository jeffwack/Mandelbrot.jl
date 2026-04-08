# Spider Algorithm

The spider algorithm computes the parameter of a quadratic polynomial from an external angle. It works by iterating a "spider" — a collection of legs connecting the critical point to infinity — until convergence.

## ``1/7``

```@example spider
using CairoMakie, BrotViz, Mandelbrot

angle = 1//7
S0 = Mandelbrot.standardspider(angle)
list = Mandelbrot.spideriterates(S0, 20)

fig = Figure()
ax = Axis(fig[1, 1])

record(fig, "spider_1_7.gif", 1:20; framerate=3) do i
    empty!(ax)
    spiderplot!(ax, list[i])
end
nothing # hide
```

![Spider algorithm for 1/7](spider_1_7.gif)

## ``2/9``

```@example spider
angle = 2//9
S0 = Mandelbrot.standardspider(angle)
list = Mandelbrot.spideriterates(S0, 20)

fig = Figure()
ax = Axis(fig[1, 1])

record(fig, "spider_2_9.gif", 1:20; framerate=3) do i
    empty!(ax)
    spiderplot!(ax, list[i])
end
nothing # hide
```

![Spider algorithm for 2/9](spider_2_9.gif)
