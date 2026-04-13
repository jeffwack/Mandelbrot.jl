# Spider Algorithm

The spider algorithm computes the parameter of a quadratic polynomial from an external angle [Hubbard_Schleicher_1995](@cite). It works by iterating a "spider" — a collection of legs connecting the critical point to infinity — until convergence.

## ``2/9``

```@example spider
using Mandelbrot
using BrotViz
using CairoMakie

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

## Introduction

```@example standardspider
using Mandelbrot
using BrotViz
using CairoMakie

theta = 9//56
S = Mandelbrot.standardspider(theta)

fig = Figure()
ax = Axis(fig[1,1])

spiderplot!(ax,S)

fig
```

```@example kneadingseq
using Mandelbrot

K = KneadingSequence(4//15)
```





## References

```@bibliography
Pages = [@__FILE__]
```

