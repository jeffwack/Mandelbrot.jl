# Binary expansion
Consider the binary expansion of a fraction between 0 and 1. 
```@example seq
using Mandelbrot
BinaryExpansion(3//10)
```
This shows 
```math
3/10 = 0.0\overline{1001}
```

We will interpret these fractions as angles, measured in full turns, so that $\frac{1}{4}$ corresponds to 90 degrees, etc.
We can interpret this sequence of digits as an itinerary describing the dynamics of this angle under repeated doubling.
To do this we first divide the circle into two halves labeled by '0' and '1'.

```math
\left[ 0,1/2 \right) \rightarrow 0 ;
\left(1/2), 1 \right) \rightarrow 1
```

We compute the orbit of our angle by iteratively doubling.

```@example seq
orbit(3//10)
```

```math
3/10 \rightarrow 3/5 \rightarrow 1/5 \rightarrow 2/5 \rightarrow 4/5 \rightarrow 3/5 \rightarrow...
```

Notice that since we are dealing with angles, we take all fractions modulo 1, so that $6/5 = 1/5$ and $8/5 = 3/5$.
We then assign each angle to the symbol corresponding to the interval it lays in. 

Notice that doubling an angle corrresponds to shifting its binary expansion by one digit.

# Kneading sequences
A kneading sequence is an infinite sequence of symbols from the set $\{A,B,*\}$. This sequence encodes the itinerary of an angle $\theta$ under the doubling map, where $A$ denotes the interval $(\frac{\theta}{2},\frac{\theta+1}{2})$, $B$ the interval  $(\frac{\theta+1}{2},\frac{\theta}{2})$, and $*$ is a kind of wildcard, assigned to the angles which fall exactly in the set $\{\frac{\theta+1}{2},\frac{\theta}{2}\}$
