# TODO: Spider Algorithm Convergence Fix (Issue #2)

**Priority**: High  
**Location**: `src/spidermap.jl:187` - Fixed iteration count instead of tolerance-based convergence  
**Current Status**: Algorithm uses primitive convergence criteria

## Problem Statement

The spider algorithm currently uses fixed iteration counts rather than robust tolerance-based convergence, as indicated by the TODO comment at line 187:

```julia
#TODO modify below to have tolerance-based convergence behavior
```

This leads to several issues:
1. **Inefficient computation**: Fixed iterations may be too many or too few
2. **Poor convergence detection**: No early termination when converged
3. **Lack of error metrics**: No indication of solution quality
4. **No stagnation detection**: Algorithm may run indefinitely on difficult cases

## Current Implementation Analysis

### Existing `parameter` Function (Lines 188-201)
```julia
function parameter(S0::Spider,max_iter::Int)
    S = deepcopy(S0)
    c_last = S.legs[2][end]/2 
    for ii in 1:max_iter
        mapspider!(S)
        c = S.legs[2][end]/2
        #println(repr(c)*" delta "*repr(abs(c-c_last)))
        if abs(c-c_last)<(1e-15)  # Hardcoded tolerance!
            return c
        end
        c_last = c
    end
    return S.legs[2][end]/2  # May not be converged
end
```

### Problems with Current Approach
1. **Single error metric**: Only parameter difference `abs(c-c_last)`
2. **Fixed tolerance**: Hardcoded `1e-15` may be too strict or too loose
3. **No convergence status**: Returns parameter without indicating if converged
4. **No adaptive behavior**: Same tolerance for all angles and iterations
5. **No stagnation detection**: Continues even if not making progress

## Mathematical Background

### Spider Algorithm Convergence Theory
From Hubbard & Schleicher (1995):
- **Fixed point theorem**: Spider map is contractive in appropriate metric
- **Convergence rate**: Geometric convergence when well-conditioned
- **Failure modes**: Near bifurcation boundaries, convergence may be slow or fail

### Error Metrics for Spider Algorithm
Multiple metrics are needed for robust convergence:

1. **Parameter Error**: `|c_new - c_old|` (current implementation)
2. **Functional Error**: How well current parameter satisfies spider equation
3. **Geometric Error**: How well spider legs maintain required properties
4. **Relative Error**: Normalized by parameter magnitude

## Proposed Enhanced Convergence Implementation

### 1. Robust Result Structure
```julia
struct SpiderResult
    parameter::Complex{Float64}
    iterations::Int
    status::Symbol  # :converged, :max_iterations, :stagnated, :diverged
    final_error::Float64
    error_history::Vector{Float64}
    convergence_metrics::Dict{Symbol, Float64}
end
```

### 2. Multi-Metric Error Function
```julia
function spider_error_metrics(c_new::Complex, c_old::Complex, S::Spider, 
                             theta::Rational)
    # Primary metric: Parameter change
    parameter_error = abs(c_new - c_old)
    
    # Secondary metric: Relative error (avoid division by zero)
    relative_error = parameter_error / max(abs(c_new), 1e-16)
    
    # Geometric metric: Spider leg consistency
    geometric_error = compute_leg_consistency_error(S, theta)
    
    # Functional metric: How well does parameter satisfy spider equation
    functional_error = compute_spider_functional_error(c_new, theta)
    
    return Dict(
        :parameter => parameter_error,
        :relative => relative_error, 
        :geometric => geometric_error,
        :functional => functional_error,
        :combined => max(parameter_error, relative_error, geometric_error)
    )
end

function compute_leg_consistency_error(S::Spider, theta::Rational)
    # Check if spider legs maintain expected geometric relationships
    # This could include:
    # - Angular separation consistency
    # - Radial ordering preservation  
    # - Intersection detection as error metric
    
    consistency_violations = 0.0
    
    # Example: Check if legs maintain proper angular ordering
    angles = [angle(leg[1]) for leg in S.legs if length(leg) > 0]
    if length(angles) > 1
        expected_angles = [angle(exp(2π*im*theta*2^(j-1))) for j in 1:length(angles)]
        angle_errors = [abs(angles[i] - expected_angles[i]) for i in 1:length(angles)]
        consistency_violations = maximum(angle_errors)
    end
    
    return consistency_violations
end

function compute_spider_functional_error(c::Complex, theta::Rational)
    # Compute how well the parameter c satisfies the spider functional equation
    # This is mathematically rigorous but computationally expensive
    # For now, return placeholder that can be implemented later
    return 0.0  # TODO: Implement based on spider theory
end
```

### 3. Adaptive Tolerance Strategy
```julia
function adaptive_tolerance(base_tolerance::Float64, iteration::Int, 
                          error_history::Vector{Float64}, theta::Rational)
    # Start with base tolerance
    current_tolerance = base_tolerance
    
    # Relax tolerance slightly as iterations increase (avoids infinite loops)
    iteration_factor = 1.0 + 0.01 * sqrt(iteration)
    current_tolerance *= iteration_factor
    
    # For angles near bifurcations, relax tolerance
    if is_near_bifurcation(theta)
        current_tolerance *= 2.0
    end
    
    # For very small parameters, use relative tolerance
    if length(error_history) > 0 && abs(error_history[end]) < 1e-10
        current_tolerance = max(current_tolerance, 1e-12)
    end
    
    return current_tolerance
end

function is_near_bifurcation(theta::Rational)
    # Detect if theta is close to a bifurcation point
    # This is heuristic and could be improved with mathematical analysis
    
    # Simple heuristic: check if denominator has large prime factors
    denom = denominator(theta)
    return denom > 100  # Large denominators often near bifurcations
end
```

### 4. Stagnation Detection
```julia
function detect_stagnation(error_history::Vector{Float64}, 
                          stagnation_window::Int = 10,
                          improvement_threshold::Float64 = 0.1)
    if length(error_history) < stagnation_window
        return false
    end
    
    # Check if error hasn't improved significantly in recent iterations
    recent_errors = error_history[end-stagnation_window+1:end]
    min_recent = minimum(recent_errors)
    max_recent = maximum(recent_errors)
    
    # If the range of recent errors is small relative to the minimum,
    # we're likely stagnating
    relative_improvement = (max_recent - min_recent) / max(min_recent, 1e-16)
    
    return relative_improvement < improvement_threshold
end
```

### 5. Enhanced Parameter Function
```julia
function parameter(S0::Spider; 
                  max_iter::Int = 1000,
                  tolerance::Float64 = 1e-12,
                  adaptive_tolerance_enabled::Bool = true,
                  stagnation_detection::Bool = true,
                  verbose::Bool = false)
    
    S = deepcopy(S0)
    c_last = S.legs[2][end]/2
    error_history = Float64[]
    
    for iter in 1:max_iter
        # Perform spider iteration
        mapspider!(S)
        c_current = S.legs[2][end]/2
        
        # Compute comprehensive error metrics
        theta = S.angle  # Assuming Spider struct has angle field
        error_metrics = spider_error_metrics(c_current, c_last, S, theta)
        primary_error = error_metrics[:combined]
        
        push!(error_history, primary_error)
        
        # Determine current tolerance (adaptive or fixed)
        current_tolerance = adaptive_tolerance_enabled ? 
            adaptive_tolerance(tolerance, iter, error_history, theta) : tolerance
            
        if verbose && iter % 10 == 0
            @info "Spider iteration $iter: error = $primary_error, tolerance = $current_tolerance"
        end
        
        # Check for convergence
        if primary_error < current_tolerance
            return SpiderResult(
                c_current, iter, :converged, primary_error, 
                error_history, error_metrics
            )
        end
        
        # Check for stagnation
        if stagnation_detection && iter > 20 && detect_stagnation(error_history)
            @warn "Spider algorithm stagnating at iteration $iter for angle $theta"
            return SpiderResult(
                c_current, iter, :stagnated, primary_error,
                error_history, error_metrics
            )
        end
        
        # Check for divergence (error increasing rapidly)
        if iter > 10 && primary_error > 2 * error_history[end-5]
            @warn "Spider algorithm diverging at iteration $iter for angle $theta"
            return SpiderResult(
                c_current, iter, :diverged, primary_error,
                error_history, error_metrics  
            )
        end
        
        c_last = c_current
    end
    
    # Maximum iterations reached
    @warn "Spider algorithm reached maximum iterations ($max_iter) for angle $(S0.angle)"
    return SpiderResult(
        S.legs[2][end]/2, max_iter, :max_iterations, 
        error_history[end], error_history, 
        spider_error_metrics(S.legs[2][end]/2, c_last, S, S0.angle)
    )
end
```

### 6. Convenience Wrapper Functions
```julia
# Maintain backward compatibility
function parameter(S0::Spider, max_iter::Int)
    result = parameter(S0, max_iter=max_iter)
    if result.status == :converged
        return result.parameter
    else
        @warn "Spider algorithm did not converge: $(result.status)"
        return result.parameter  # Return best estimate
    end
end

# New interface for external angles
function parameter(theta::Rational; kwargs...)
    S = standardspider(theta)
    return parameter(S; kwargs...)
end

# Batch processing with convergence analysis
function parameter_batch(angles::Vector{Rational}; kwargs...)
    results = SpiderResult[]
    
    for theta in angles
        try
            result = parameter(theta; kwargs...)
            push!(results, result)
        catch e
            @error "Failed to compute parameter for angle $theta: $e"
            # Create failure result
            push!(results, SpiderResult(
                NaN + NaN*im, 0, :failed, Inf, Float64[], Dict{Symbol,Float64}()
            ))
        end
    end
    
    return results
end
```

## Testing Strategy

### Convergence Quality Tests
```julia
@testset "Spider Convergence Quality" begin
    # Test basic convergence
    result = parameter(1//3, tolerance=1e-12)
    @test result.status == :converged
    @test result.final_error < 1e-12
    @test result.iterations < 1000  # Should converge quickly for this case
    
    # Test tolerance sensitivity  
    tight_result = parameter(1//7, tolerance=1e-15)
    loose_result = parameter(1//7, tolerance=1e-8)
    @test tight_result.iterations >= loose_result.iterations
    @test tight_result.final_error <= loose_result.final_error
    
    # Test adaptive tolerance
    adaptive_result = parameter(1//3, adaptive_tolerance_enabled=true)
    fixed_result = parameter(1//3, adaptive_tolerance_enabled=false)
    @test adaptive_result.status == :converged
    @test fixed_result.status == :converged
end
```

### Robustness Tests  
```julia
@testset "Spider Convergence Robustness" begin
    # Test difficult cases that might stagnate
    difficult_angles = [7//30, 11//42, 13//56]  # Heuristically chosen
    
    for theta in difficult_angles
        result = parameter(theta, stagnation_detection=true, max_iter=2000)
        @test result.status in [:converged, :stagnated]
        @test !isnan(result.parameter)  # Should always return valid number
    end
    
    # Test batch processing
    test_angles = [1//3, 1//7, 2//7, 3//7, 4//15]
    results = parameter_batch(test_angles, tolerance=1e-10)
    @test length(results) == length(test_angles)
    @test all(r -> r.status in [:converged, :stagnated], results)
end
```

### Performance Comparison Tests
```julia
@testset "Spider Convergence Performance" begin
    # Compare old vs new implementation performance
    theta = 1//7
    
    # Time old implementation
    @time old_result = parameter(standardspider(theta), 100)  # Old signature
    
    # Time new implementation
    @time new_result = parameter(theta, max_iter=100)
    
    # Both should give similar results
    @test abs(old_result - new_result.parameter) < 1e-10
    
    # New implementation should provide more information
    @test new_result.status isa Symbol
    @test new_result.iterations <= 100
    @test length(new_result.error_history) == new_result.iterations
end
```

## Implementation Plan

### Phase 1: Core Implementation (1 week)
1. **Define SpiderResult structure** and error metric functions
2. **Implement enhanced parameter function** with multi-metric convergence
3. **Add adaptive tolerance and stagnation detection**

### Phase 2: Integration and Testing (1 week)  
1. **Update existing code** to use new parameter function signature
2. **Implement comprehensive test suite** covering edge cases
3. **Performance testing** to ensure no significant slowdown

### Phase 3: Documentation and Optimization (1 week)
1. **Document new convergence behavior** and parameter options
2. **Optimize performance** based on profiling results
3. **Add examples** showing improved convergence diagnostics

## Success Criteria

- [ ] TODO comment at line 187 resolved
- [ ] Tolerance-based convergence implemented with multiple error metrics
- [ ] Adaptive tolerance adjusts based on problem difficulty
- [ ] Stagnation detection prevents infinite loops
- [ ] SpiderResult provides comprehensive convergence information
- [ ] Backward compatibility maintained for existing code
- [ ] Performance is maintained or improved
- [ ] Comprehensive test suite validates robustness
- [ ] Documentation explains new convergence options

## Related Issues

- **Issue #1**: Periodic case handling (convergence behavior may differ for periodic vs preperiodic)
- **Issue #3**: Leg intersection detection (completed - may interact with geometric error metrics)
- May improve reliability of `HyperbolicComponent` parameter calculations

## References

- Hubbard, J.H. & Schleicher, D. (1995): "The Spider Algorithm" - Convergence theory
- `src/spidermap.jl:187-205` - Current implementation needing enhancement
- Numerical analysis literature on iterative method convergence
- Complex dynamics literature on parameter space algorithms