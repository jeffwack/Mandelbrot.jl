We will be sampling the Mandelbrot set in a rectangular grid and rendering each point as a square pixel. Doing this requires making some decisions.
1. how many pixels? N::Int -> 1000x1000
2. location, scale, and orientation? (center::Complex, middle_left::Complex)  
3. max number of iterations? maxiter::Int -> unknown function of unknown variables. "distance from the set" with "the right" metric
4. stop condition? stop()::Function{Complex -> boolean}
5. color? color()::Function{IteratorState -> RGB}

# Some recipes for generating pictures 

1. External rays (vector)
* Parameter
* Angle
* Radius of 'infinity'
* Segment resolution
* Depth
* Colors

2. External Binary decomposition (raster)
* Parameter
* Grid size
* Grid location
* Radius of 'infinity'
* Angle of decomposition
* Max iter ~ depth
* Colors

3. Escape Time (raster)
* Parameter
* Grid size 
* Grid location
* Max iter ~ depth
* Escape radius ~ radius of 'infinity'
* Colors 

4. Inverse Iterate (vector)
* Parameter
* Start point
* Number of generations
-question: should all generations be plotted? or just the last? does it matter?

# Combos
From angle:
Boundary of the Julia set with inverse iterates
+
Hubbard tree inside
+
External rays outside

From angle:
Binary decomp outside
+
Binary decomp inside


