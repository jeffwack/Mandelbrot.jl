Dynamic rays assign an external angle to every point of the exterior of a Julia set by conjugating the dynamics of $p_c$ to the squaring map $z \rightarrow z^2$. For connected Julia sets this conjugacy is provided by the [Riemann Mapping Theorem](https://en.wikipedia.org/wiki/Riemann_mapping_theorem), and we will restrict our attention to the case of connected Julia sets for this article.

We want to "walk in" rays from infinity, by running the dynamics backwards. The seed for this "ray growing" algorithm is a collection of ray segments with the structure of an orbit. 

Take any periodic angle (these are the angles with an odd denominator!), $\theta$. Let $Orb(\theta)$ denote the orbit of $\theta$

And where am I supposed to upload pictures?


Other prerequisites:

Julia Set

```@example rays
using CairoMakie, BrotViz, Mandelbrot
S0 = Mandelbrot.standardspider(1//7)
fig = Figure()
ax = Axis(fig[1,1])
spiderplot!(ax, S0)
fig
```

```@example rays
HC = HyperbolicComponent(1//7)
rays = collect(values(HC.rays))
fig, ax = plotrays(rays)
fig
```

```@example rays
c = parameter(1//7, 500)
fig, ax = dynamicraysplot(c, 1//7)
fig
```
