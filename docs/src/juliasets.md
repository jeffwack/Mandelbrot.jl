Generating pictures of Julia sets is much-beloved computational task. Gorgeous figures emerge from so few lines of code, and the fractal nature of the sets makes no number of pixels adequate. Instead, their insufficiency only begs for more computational power, a deeper and deeper zoom. 

Much has been said and written about Julia sets, and here are some of my favorite introductions.

[Holly Krieger - Numberphile](https://www.youtube.com/watch?v=oCkQ7WK7vuY)

```@example julia
using CairoMakie, BrotViz, Mandelbrot
fig, ax, plt = juliasetplot(-0.3+0.0im, 2.0)
fig
```

```@example julia
fig, ax, plt = juliasetplot(-0.7269+0.1889im, 1.5, binary_decomposition=true)
fig
```

```@example julia
fig, ax, plt = juliasetplot(1//7, 2.0)
fig
```
