# TODO: Perturbative Mandelbrot Computation System

**Priority**: Medium  
**Location**: `ROADMAP.md:197` - Major feature for InteractiveViz.jl integration  
**Current Status**: Concept described, no implementation exists

## Problem Statement

Implement perturbative computation of Mandelbrot escape times using spider algorithm results as high-precision "core orbits" for perturbation expansions, enabling efficient rendering around hyperbolic components.

## Goal

Create a focused perturbative computation system that:
1. Uses spider algorithm legs with arbitrary precision feet as reference orbits
2. Performs perturbation expansions around a single hyperbolic component center
3. Integrates with InteractiveViz.jl for zoom-only exploration (no panning)

## Mathematical Background

**Standard Iteration**: `z_{n+1} = z_n^2 + c`

**Perturbative Approach**: Given reference orbit `Z_n` for parameter `C`, compute nearby `c = C + δc`:
- `δz_{n+1} ≈ 2Z_n δz_n + δc` (linear recurrence, much faster than full iteration)

**Spider Integration**: Spider algorithm provides high-precision hyperbolic component centers as optimal reference points.

## Implementation Plan

### Phase 1: Spider API Enhancement (1 commit)

**Prerequisites**: Improve spider algorithm API for perturbative use.

```julia
# Enhanced spider algorithm interface needed first
function spideralg(theta::Rational; tolerance=1e-16, return_legs=true)
    # Returns spider result with legs for perturbative computation
    # Need to implement this enhanced API based on existing spidermap
end
```

### Phase 2: Orbit Structure and Sequence Indexing (1-2 commits)

**Core Data Structures**: 
```julia
# Decision needed: Use composition over inheritance for clarity
struct CriticalOrbit
    parameter::BigFloat  # Spider algorithm result
    sequence::Sequence{BigComplex}  # Orbit points with high precision
end

function criticalorbit(theta::Rational)
    spider_result = spideralg(theta, tolerance=1e-16)
    # Extract foot (confirm: is foot at end of spider legs?)
    orbit_points = spider_result[:, end]  # Custom sequence indexing needed
    return CriticalOrbit(spider_result.parameter, orbit_points)
end
```

**Sequence Enhancement**: Implement custom indexing `seq[:,end]` that creates new sequence with specified elements from collections.

### Phase 3: Perturbation Engine (2 commits)

**Single-Point Perturbation**: Focus on perturbation around one hyperbolic component.

```julia
struct PerturbationCalculator
    reference_orbit::CriticalOrbit
    tolerance::Float64  # When to fall back to direct iteration
    max_iterations::Int
end

function compute_escape_time_perturbative(calc::PerturbationCalculator, c::Complex)
    δc = c - calc.reference_orbit.parameter
    δz = zero(ComplexF64)
    
    for n in 1:min(length(calc.reference_orbit.sequence), calc.max_iterations)
        Z_n = calc.reference_orbit.sequence[n]
        
        # Perturbative step: δz_{n+1} ≈ 2Z_n δz_n + δc
        δz = 2 * Z_n * δz + δc
        
        # Check escape condition
        if abs2(Z_n + δz) > 4
            return n
        end
        
        # Fall back to direct iteration if perturbation becomes large
        if abs(δz) > calc.tolerance * abs(Z_n)
            return compute_escape_time_direct(c, n)
        end
    end
    
    return calc.max_iterations
end
```

### Phase 4: InteractiveViz Integration (1-2 commits)

**Zoom-Only Exploration**: InteractiveViz.jl integration focused on zooming around fixed hyperbolic component center.

```julia
struct PerturbativeMandelbrotDataSource
    calculator::PerturbationCalculator
    center::Complex  # Fixed center point from spider algorithm
    max_iterations::Int
end

function InteractiveViz.sample(ds::PerturbativeMandelbrotDataSource, 
                              zoom_region::Complex, zoom_level::Float64, 
                              resolution::Int)
    # Generate points centered on ds.center with given zoom level
    # No panning - only zoom in/out around the fixed hyperbolic component
    
    half_width = zoom_level / 2
    real_range = range(real(ds.center) - half_width, 
                      real(ds.center) + half_width, length=resolution)
    imag_range = range(imag(ds.center) - half_width,
                      imag(ds.center) + half_width, length=resolution)
    
    escape_times = Matrix{Int}(undef, resolution, resolution)
    
    Threads.@threads for i in 1:resolution
        for j in 1:resolution
            c = Complex(real_range[i], imag_range[j])
            escape_times[i, j] = compute_escape_time_perturbative(ds.calculator, c)
        end
    end
    
    return escape_times
end

function create_hyperbolic_explorer(theta::Rational)
    # Create perturbative explorer for specific hyperbolic component
    orbit = criticalorbit(theta)
    calc = PerturbationCalculator(orbit, 1e-6, 1000)
    datasource = PerturbativeMandelbrotDataSource(calc, orbit.parameter, 1000)
    
    return InteractiveViz.plot(datasource)
end
```

## Key Questions to Resolve

1. **Spider Algorithm API**: Design enhanced `spideralg()` interface for perturbative use
2. **Foot Location**: Confirm spider algorithm foot is at `end` of legs  
3. **Sequence Indexing**: Implement `seq[:,end]` custom indexing for sequences of collections
4. **InteractiveViz.jl API**: Research correct `sample()` method signature for zoom-only interface

## Success Criteria

- [ ] Enhanced spider algorithm API implemented
- [ ] Sequence custom indexing working for `seq[:,end]`
- [ ] Perturbative computation 10x+ faster than direct iteration  
- [ ] InteractiveViz.jl zoom-only interface functional
- [ ] Accuracy within 2 iterations of direct computation
- [ ] Integration with CLI address navigation system

## Implementation Dependencies

1. **Prerequisite**: Spider algorithm fixes (see `TODO_spider_algorithm_fixes.md`)
2. **Prerequisite**: Sequence framework enhancements (custom indexing)
3. **Research**: InteractiveViz.jl API for zoom-only data sources
4. **Integration**: CLI interface for hyperbolic component selection

## References

- Perturbation theory in fractal computation
- InteractiveViz.jl documentation (research needed)
- Spider algorithm implementation (`src/spidermap.jl`)
