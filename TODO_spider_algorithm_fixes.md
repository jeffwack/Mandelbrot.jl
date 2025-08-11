# TODO: Spider Algorithm Correctness and Robustness Fixes

**Priority**: High  
**Location**: `src/spidermap.jl` - Multiple algorithmic issues identified  
**Current Status**: Algorithm implemented but has known correctness and convergence issues

## Problem Statement

The spider algorithm has several critical issues that affect its reliability:
1. **Periodic case handling incomplete** (`src/spidermap.jl:97`)
2. **Fixed iteration count instead of tolerance-based convergence** (`src/spidermap.jl:174`)
3. **Correctness issue: Legs may intersect, need subdivision testing**

## Goal

Fix all identified spider algorithm issues to ensure mathematical correctness and robust convergence.

## Issues Analysis

### Issue 1: Periodic Case Handling (`src/spidermap.jl:97`)

**Current Problem**:
```julia
#TODO what is going on with the periodic case? kneading sequences never have 1s and 2s now
```

**Investigation Required**:
- [ ] Identify what "1s and 2s" refers to in the comment
- [ ] Understand how periodic cases differ from preperiodic
- [ ] Determine if this relates to `Digit{2}` vs `KneadingSymbol` types

**Potential Fix Strategy**:
```julia
function handle_periodic_case(theta::Rational, max_iterations::Int)
    # Special logic for purely periodic sequences
    if is_purely_periodic(theta)
        # Implement specialized periodic spider algorithm
        return periodic_spider_map(theta, max_iterations)
    else
        # Use general algorithm
        return general_spider_map(theta, max_iterations)
    end
end
```

### Issue 2: Tolerance-Based Convergence (`src/spidermap.jl:174`)

**Current Problem**:
```julia
#TODO modify below to have tolerance-based convergence behavior
```

**Current Implementation** (Fixed iterations):
```julia
function spidermap(theta::Rational, iterations::Int=50)
    # ... setup
    for i in 1:iterations  # Fixed iteration count
        # ... spider step
    end
    # ... return result
end
```

**Proposed Fix**:
```julia
function spidermap(theta::Rational; 
                  max_iterations::Int=1000, 
                  tolerance::Float64=1e-12,
                  adaptive_tolerance::Bool=true)
    
    previous_estimate = initial_spider_estimate(theta)
    
    for i in 1:max_iterations
        current_estimate = spider_step(previous_estimate, theta)
        
        # Calculate error metric
        error = spider_error_metric(current_estimate, previous_estimate, theta)
        
        # Adaptive tolerance based on iteration count
        current_tolerance = adaptive_tolerance ? 
            tolerance * (1.0 + 0.1 * sqrt(i)) : tolerance
        
        if error < current_tolerance
            return SpiderResult(current_estimate, i, :converged, error)
        end
        
        # Check for stagnation
        if i > 10 && error > previous_error * 0.99
            @warn "Spider algorithm stagnating at iteration $i"
        end
        
        previous_estimate = current_estimate
        previous_error = error
    end
    
    return SpiderResult(current_estimate, max_iterations, :max_iterations, error)
end

struct SpiderResult
    parameter::Complex
    iterations::Int
    status::Symbol  # :converged, :max_iterations, :diverged
    final_error::Float64
end
```

### Issue 3: Leg Intersection Detection

**Critical Correctness Issue**: Spider legs may intersect, requiring subdivision.

**Investigation Required**:
- [ ] Understand when leg intersection occurs
- [ ] Implement intersection detection algorithm
- [ ] Design subdivision strategy

**Proposed Implementation**:
```julia
function detect_leg_intersections(spider_legs::Vector{Vector{Complex}})
    intersections = []
    
    for i in 1:length(spider_legs)-1
        for j in i+1:length(spider_legs)
            intersection_points = find_curve_intersections(spider_legs[i], spider_legs[j])
            if !isempty(intersection_points)
                push!(intersections, (i, j, intersection_points))
            end
        end
    end
    
    return intersections
end

function subdivide_intersecting_legs(spider_legs, intersections)
    # Implement subdivision algorithm
    # This may require refining the parameter mesh
    subdivided_legs = copy(spider_legs)
    
    for (leg1_idx, leg2_idx, intersection_points) in intersections
        # Refine both legs around intersection points
        subdivided_legs[leg1_idx] = refine_leg_around_points(
            subdivided_legs[leg1_idx], intersection_points
        )
        subdivided_legs[leg2_idx] = refine_leg_around_points(
            subdivided_legs[leg2_idx], intersection_points
        )
    end
    
    return subdivided_legs
end

function safe_spider_map(theta::Rational; subdivision_threshold::Int=5)
    result = spidermap(theta)
    
    # Check if result is reliable
    spider_legs = compute_spider_legs(result.parameter, theta)
    intersections = detect_leg_intersections(spider_legs)
    
    if length(intersections) > subdivision_threshold
        @warn "Many leg intersections detected, subdividing"
        refined_legs = subdivide_intersecting_legs(spider_legs, intersections)
        # Recompute spider map with refined data
        result = spidermap_with_refined_legs(theta, refined_legs)
    end
    
    return result
end
```

## Mathematical Background Investigation

### Understanding Spider Algorithm Theory
- [ ] Review Hubbard & Schleicher spider paper
- [ ] Understand when algorithm is guaranteed to converge
- [ ] Identify failure modes and their mathematical causes
- [ ] Document assumptions made by current implementation

### Error Metrics
```julia
function spider_error_metric(current::Complex, previous::Complex, theta::Rational)
    # Multiple error measures for robustness
    parameter_error = abs(current - previous)
    
    # Functional error: how well does current parameter satisfy spider equation
    functional_error = abs(spider_functional(current, theta))
    
    # Leg consistency: how well do spider legs match expected pattern
    leg_error = compute_leg_consistency_error(current, theta)
    
    return max(parameter_error, functional_error, leg_error)
end

function spider_functional(c::Complex, theta::Rational)
    # The spider functional that should be zero at the correct parameter
    # This needs to be implemented based on spider theory
end
```

## Implementation Plan

### Phase 1: Investigation and Analysis (1 commit)
- [ ] **Analyze current algorithm** in detail
  - Map out the complete spider algorithm flow
  - Identify all mathematical assumptions
  - Document current parameter ranges that work/fail

- [ ] **Research theoretical issues**
  - Review spider algorithm literature  
  - Understand periodic vs preperiodic differences
  - Identify when leg intersections occur

- [ ] **Create test cases for known failures**
  - Find parameter values where algorithm fails
  - Document failure modes
  - Create minimal reproduction cases

### Phase 2: Convergence Improvements (1 commit)
- [ ] **Implement tolerance-based convergence**
  - Replace fixed iteration counts
  - Add multiple error metrics
  - Implement adaptive tolerance
  - Add convergence diagnostics

- [ ] **Add result validation**
  - Verify spider legs have correct properties
  - Check parameter value makes mathematical sense
  - Add confidence metrics to results

### Phase 3: Periodic Case Fix (1 commit)
- [ ] **Investigate "1s and 2s" comment**
  - Understand what this refers to historically
  - Check if relates to binary vs kneading representation
  - Implement proper periodic case handling

- [ ] **Test periodic cases thoroughly**
  - Create test suite for periodic parameters
  - Verify convergence for known periodic cases
  - Compare with literature results

### Phase 4: Leg Intersection Handling (1-2 commits)
- [ ] **Implement intersection detection**
  - Algorithm to detect curve intersections
  - Efficient geometric computation
  - Handle numerical precision issues

- [ ] **Implement subdivision strategy**  
  - Refine parameter mesh around intersections
  - Maintain mathematical correctness
  - Balance accuracy vs computational cost

- [ ] **Integration and validation**
  - Integrate all fixes into main algorithm
  - Comprehensive testing of edge cases
  - Performance optimization

## Test Cases Required

### Basic Convergence Tests
```julia
@testset "Spider Algorithm Convergence" begin
    # Known good cases
    @test spidermap(1//3).status == :converged
    @test spidermap(1//7).status == :converged
    
    # Tolerance verification
    result = spidermap(1//3, tolerance=1e-15)
    @test result.final_error < 1e-15
end
```

### Periodic Case Tests
```julia
@testset "Periodic Cases" begin
    # Period-1 (main cardioid)
    result = spidermap(1//1)
    @test result.status == :converged
    
    # Period-2 (main bulb)
    result = spidermap(1//2) 
    @test result.status == :converged
end
```

### Robustness Tests
```julia
@testset "Algorithm Robustness" begin
    # Cases known to cause leg intersections
    problematic_angles = [3//7, 5//12, 7//15]  # Example problematic cases
    
    for theta in problematic_angles
        result = safe_spider_map(theta)
        @test result.status in [:converged, :subdivided_converged]
    end
end
```

## Success Criteria

- [ ] All TODO comments in `src/spidermap.jl` resolved
- [ ] Tolerance-based convergence implemented and tested
- [ ] Periodic cases handled correctly
- [ ] Leg intersection detection working
- [ ] Algorithm robustness significantly improved
- [ ] Comprehensive test suite covering edge cases
- [ ] Performance maintained or improved
- [ ] Documentation updated with new features

## Related Issues

- May affect `HyperbolicComponent` parameter calculation
- Impacts visualization quality in `treeplot`
- Critical for CLI interface reliability

## References

- `src/spidermap.jl` (current implementation)
- Hubbard & Schleicher spider algorithm paper
- `src/spiderfuncs.jl` (supporting functions)
- Mathematical literature on spider algorithms