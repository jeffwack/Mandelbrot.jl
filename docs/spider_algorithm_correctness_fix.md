# Spider Algorithm Correctness Fix: Issue #3 Implementation Plan

## Overview

This document outlines the implementation plan for fixing Issue #3 in the spider algorithm: **leg intersection detection and subdivision**. The spider algorithm is used to compute hyperbolic component parameters in the Mandelbrot set, but the current implementation lacks collision detection, leading to mathematical incorrectness when spider legs intersect.

## Problem Statement

### Current Issues
1. **Missing Intersection Detection**: Spider legs (represented as `Vector{ComplexF64}`) can intersect during iteration, violating mathematical assumptions
2. **Geometric Violations**: When legs cross, the algorithm loses injectivity and homotopy class correctness
3. **Convergence Failures**: Intersection violations can prevent proper convergence to hyperbolic component centers

### Mathematical Background
The spider algorithm maps complex polynomial dynamics to combinatorial data through "spider legs" - curves connecting critical orbit points to infinity. These legs must maintain specific geometric properties:
- **Injectivity**: No two legs can intersect except at infinity
- **Homotopy Class Preservation**: Leg deformations must preserve topological relationships
- **Circular Order**: Legs maintain consistent angular ordering around infinity

## Literature Review

### Hubbard & Schleicher (1995) Implementation Conditions

The original paper provides **three geometric tests** for intersection detection:

#### 1. Line Side Test
**Condition**: Endpoint `z̃j` must be on the same side as `-d` relative to the reference line
- Ensures proper geometric relationship with critical point

#### 2. Hyperbola Interior Test  
**Condition**: Points `zj+1` and `0` must be on **opposite sides** of the segment line
- Detects when endpoints fall within curved preimage regions
- Critical for identifying potential intersections

#### 3. Angular Separation Test
**Condition**: From critical point `-d`, angle between `z̃j` and hyperbola endpoints < `π/d`
- **Most important test** for intersection detection
- When this fails, legs intersect and require subdivision

### Current Implementation Analysis

**File**: `/src/spidermap.jl`
- **Spider struct**: Contains `legs::Vector{Vector{ComplexF64}}` - sequences of complex points
- **mapspider! function** (lines 55-163): Core iteration mapping legs through polynomial
- **No intersection detection**: Algorithm proceeds without geometric validation

**Critical Location**: Lines 153-162 where `newLegs` are computed and transformed
```julia
for leg in newLegs
    leg .+= (-1.0+0.0im)
end
newLegs .*= (2.0+0.0im)
grow!(newLegs,10,10)
```

## Implementation Plan

### Phase 1: Intersection Detection Functions

#### Function 1: `detect_leg_intersections`
```julia
function detect_leg_intersections(legs::Vector{Vector{ComplexF64}})
    intersections = []
    
    for i in 1:length(legs)-1
        for j in i+1:length(legs)
            intersection_points = find_curve_intersections(legs[i], legs[j])
            if !isempty(intersection_points)
                push!(intersections, (i, j, intersection_points))
            end
        end
    end
    
    return intersections
end
```

#### Function 2: `check_hubbard_conditions`
Based on Hubbard & Schleicher's three tests:
```julia
function check_hubbard_conditions(zj_tilde::ComplexF64, zj_plus1::ComplexF64, 
                                 segment_start::ComplexF64, segment_end::ComplexF64,
                                 d::Int = 2)
    # Test 1: Line side test
    critical_point = -d + 0.0im
    line_side_ok = same_side_of_line(zj_tilde, critical_point, segment_start, segment_end)
    
    # Test 2: Hyperbola interior test  
    opposite_sides = different_sides_of_line(zj_plus1, 0.0+0.0im, segment_start, segment_end)
    
    # Test 3: Angular separation test (< π/d)
    angle1 = angle(zj_tilde - critical_point)
    angle2 = angle(segment_start - critical_point) 
    angle3 = angle(segment_end - critical_point)
    angle_ok = min(abs(angle1 - angle2), abs(angle1 - angle3)) < π/d
    
    return line_side_ok && opposite_sides && angle_ok
end
```

### Phase 2: Subdivision Strategy

#### Function 3: `subdivide_intersecting_legs`
```julia
function subdivide_intersecting_legs(legs::Vector{Vector{ComplexF64}}, 
                                   intersections, max_subdivisions::Int = 5)
    subdivided_legs = deepcopy(legs)
    
    for (leg1_idx, leg2_idx, intersection_points) in intersections
        # Recursive subdivision around intersection points
        subdivided_legs[leg1_idx] = refine_leg_around_intersections(
            subdivided_legs[leg1_idx], intersection_points, max_subdivisions
        )
        subdivided_legs[leg2_idx] = refine_leg_around_intersections(
            subdivided_legs[leg2_idx], intersection_points, max_subdivisions
        )
    end
    
    return subdivided_legs
end
```

#### Function 4: `refine_leg_around_intersections`
```julia
function refine_leg_around_intersections(leg::Vector{ComplexF64}, 
                                       intersections, max_depth::Int)
    if max_depth <= 0 || length(leg) < 2
        return leg
    end
    
    refined_leg = ComplexF64[]
    
    for i in 1:length(leg)-1
        push!(refined_leg, leg[i])
        
        # Check if this segment needs refinement
        segment_needs_refinement = false
        for intersection_point in intersections
            if point_near_segment(intersection_point, leg[i], leg[i+1])
                segment_needs_refinement = true
                break
            end
        end
        
        if segment_needs_refinement
            # Add midpoint and recursively refine
            midpoint = (leg[i] + leg[i+1]) / 2
            push!(refined_leg, midpoint)
        end
    end
    
    push!(refined_leg, leg[end])
    
    # Recursive call with reduced depth
    if length(refined_leg) > length(leg)
        return refine_leg_around_intersections(refined_leg, intersections, max_depth - 1)
    else
        return refined_leg
    end
end
```

### Phase 3: Integration into mapspider!

**Location**: After line 162, before updating `S.legs`:

```julia
function mapspider!(S::Spider)
    # ... existing code through line 162 ...
    
    # NEW: Intersection detection and subdivision
    intersections = detect_leg_intersections(newLegs)
    
    if !isempty(intersections)
        @debug "Spider leg intersections detected: $(length(intersections)) intersections"
        
        # Apply subdivision strategy
        newLegs = subdivide_intersecting_legs(newLegs, intersections)
        
        # Verify subdivision resolved intersections
        remaining_intersections = detect_leg_intersections(newLegs)
        if !isempty(remaining_intersections)
            @warn "Subdivision did not fully resolve intersections: $(length(remaining_intersections)) remaining"
        end
    end
    
    # Continue with existing code
    for ii in eachindex(S.legs)
        S.legs[ii] = copy(newLegs[ii])
    end
    return S
end
```

### Phase 4: Enhanced Convergence

#### Tolerance-Based Convergence
Update `parameter` function (lines 188-201):

```julia
function parameter(S0::Spider; max_iter::Int = 1000, 
                  tolerance::Float64 = 1e-12,
                  subdivision_threshold::Int = 5)
    S = deepcopy(S0)
    c_last = S.legs[2][end]/2 
    
    for ii in 1:max_iter
        mapspider!(S)
        c = S.legs[2][end]/2
        
        # Multiple convergence criteria
        parameter_error = abs(c - c_last)
        
        # Additional error metrics
        if parameter_error < tolerance
            return SpiderResult(c, ii, :converged, parameter_error)
        end
        
        # Check for stagnation
        if ii > 10 && parameter_error > abs(c_last) * 0.99
            @warn "Spider algorithm may be stagnating at iteration $ii"
        end
        
        c_last = c
    end
    
    return SpiderResult(S.legs[2][end]/2, max_iter, :max_iterations, abs(c_last))
end
```

#### Result Structure
```julia
struct SpiderResult
    parameter::Complex
    iterations::Int
    status::Symbol  # :converged, :max_iterations, :subdivisions_failed
    final_error::Float64
    intersections_detected::Int
end
```

## Testing Strategy

### Unit Tests
1. **Intersection Detection Tests**:
   - Known intersecting leg configurations
   - Edge cases (tangent legs, near-misses)
   - Performance with large numbers of legs

2. **Subdivision Tests**:
   - Verify subdivision resolves intersections
   - Check preservation of endpoint positions
   - Validate homotopy class maintenance

3. **Integration Tests**:
   - Known good parameter values (θ = 1//3, 1//7)
   - Previously problematic cases from TODO document
   - Convergence validation

### Regression Tests
```julia
@testset "Spider Algorithm Correctness" begin
    # Basic convergence (should still work)
    @test parameter(standardspider(1//3)).status == :converged
    
    # Previously problematic cases
    problematic_angles = [3//7, 5//12, 9//56]  # From TODO examples
    for θ in problematic_angles
        result = parameter(standardspider(θ))
        @test result.status in [:converged, :subdivisions_resolved]
        @test result.final_error < 1e-10
    end
    
    # Tolerance verification
    result = parameter(standardspider(1//7), tolerance=1e-15)
    @test result.final_error < 1e-15
end
```

## Performance Considerations

### Computational Cost
- **Intersection detection**: O(n²) where n = number of legs
- **Subdivision**: Adds points locally, bounded by max_subdivisions parameter
- **Overall impact**: Should be minimal for well-behaved cases

### Optimization Strategies
1. **Early termination**: Skip intersection detection if legs are well-separated
2. **Spatial indexing**: Use grid-based acceleration for large numbers of legs
3. **Adaptive thresholds**: Adjust subdivision sensitivity based on convergence behavior

## Success Criteria

- [ ] All TODO comments in `src/spidermap.jl` resolved
- [ ] Intersection detection working with Hubbard's three tests
- [ ] Subdivision strategy successfully resolves intersections
- [ ] Enhanced tolerance-based convergence implemented
- [ ] Comprehensive test suite covering edge cases
- [ ] Algorithm robustness significantly improved
- [ ] Performance maintained or improved for typical cases
- [ ] Documentation updated with new functionality

## Implementation Timeline

1. **Week 1**: Implement intersection detection functions
2. **Week 2**: Develop and test subdivision strategy  
3. **Week 3**: Integration into mapspider! with comprehensive testing
4. **Week 4**: Enhanced convergence features and performance optimization

## References

1. **Hubbard, J.H. & Schleicher, D. (1995)**: "The Spider Algorithm" - Original implementation section
2. **TODO_spider_algorithm_fixes.md**: Current implementation issues and test cases
3. **src/spidermap.jl**: Existing spider algorithm implementation
4. **Mandelbrot.jl**: Overall package context and testing framework

---

*This document serves as the technical specification for resolving Issue #3 in the spider algorithm correctness fixes.*