# TODO: Analyze and Ensure Sequence Framework Type Stability

**Priority**: High  
**Location**: `src/Sequences.jl:29` - Performance claim about type stability  
**Current Status**: Claimed type-stable but needs verification

## Problem Statement

The roadmap claims the Sequence framework is "Type-stable with hash support for dictionary keys" but this needs verification and testing. Type stability is critical for performance in Julia.

## Goal

Verify type stability of the Sequence framework and fix any type instabilities found.

## Analysis Required

### Key Functions to Analyze

1. **Constructor** (`src/Sequences.jl:10-37`)
   ```julia
   function Sequence{T}(items::Vector{T},preperiod::Int) where T
   ```

2. **Indexing** (`src/Sequences.jl:59-66`)
   ```julia
   function Base.getindex(S::Sequence, ii::Int)
   ```

3. **Shifting** (`src/Sequences.jl:91-99`)
   ```julia
   function shift(seq::Sequence{T}) where T
   ```

4. **Property Access** (`src/Sequences.jl:40-46`)
   ```julia
   function Base.getproperty(S::Sequence,sym::Symbol)
   ```

## Tools for Analysis

### Method 1: `@code_warntype` Analysis
```julia
# Test specific operations
seq = Sequence{Int}([1,2,3,1,2,3], 2)
@code_warntype seq[5]           # Check indexing
@code_warntype shift(seq)       # Check shifting
@code_warntype seq.period       # Check property access
```

### Method 2: Type Inference Testing
```julia
using Test
@inferred seq[5]                # Should not throw if type-stable
@inferred shift(seq)            # Should not throw if type-stable
```

### Method 3: Benchmark Performance
```julia
using BenchmarkTools
seq = Sequence{Int}([1,2,3,1,2,3], 2)
@benchmark seq[5]               # Measure allocation
@benchmark shift(seq)           # Compare with type-unstable version
```

## Potential Type Instability Sources

### 1. Conditional Logic in Constructor
The constructor has complex logic for period reduction:
```julia
if length(repetend) > 1
    for d in divisors(k)
        chunks = collect.(partition(repetend,d))
        if allequal(chunks)
            repetend = chunks[1]  # Potential type change
            break
        end
    end
end
```

### 2. Dynamic Indexing
```julia
function Base.getindex(S::Sequence, ii::Int)
    if ii <= S.preperiod
        return S.items[ii]
    else
        k = length(S.items) - S.preperiod
        return S.items[mod1(ii-S.preperiod,k)]  # Complex calculation
    end
end
```

### 3. Property Getter
```julia
function Base.getproperty(S::Sequence,sym::Symbol)
    if sym === :period
        return length(S.items) - S.preperiod  # Runtime calculation
    else
        return getfield(S,sym)
    end
end
```

## Implementation Plan

### Phase 1: Analysis (1 commit)
- [ ] Create comprehensive type stability test suite
- [ ] Run `@code_warntype` on all public functions
- [ ] Document any red flags or `Any` types found
- [ ] Benchmark current performance baseline

### Phase 2: Fixes (1-2 commits depending on issues found)
- [ ] Fix any type instabilities discovered
- [ ] Add type annotations where needed
- [ ] Consider performance optimizations:
  ```julia
  # Potential optimization: cache period calculation
  struct Sequence{T}
      items::Vector{T}
      preperiod::Int
      period::Int  # Cache computed period
  end
  ```

### Phase 3: Testing (1 commit)
- [ ] Add type stability tests to test suite:
  ```julia
  @testset "Type Stability" begin
      seq = Sequence{Int}([1,2,3,1,2,3], 2)
      @test @inferred(seq[5]) isa Int
      @test @inferred(shift(seq)) isa Sequence{Int}
      @test @inferred(seq.period) isa Int
  end
  ```
- [ ] Add performance regression tests
- [ ] Document type stability guarantees

## Specific Tests to Implement

### Basic Type Stability
```julia
@testset "Sequence Type Stability" begin
    # Integer sequences
    int_seq = Sequence{Int}([1,2,3,1,2], 1)
    @test @inferred(int_seq[3]) === 3
    @test @inferred(shift(int_seq)) isa Sequence{Int}
    
    # KneadingSymbol sequences
    ks_seq = KneadingSequence([KneadingSymbol('A'), KneadingSymbol('B')], 0)
    @test @inferred(ks_seq[1]) isa KneadingSymbol
    @test @inferred(shift(ks_seq)) isa KneadingSequence
    
    # Property access
    @test @inferred(int_seq.period) isa Int
    @test @inferred(int_seq.preperiod) isa Int
end
```

### Performance Tests
```julia
@testset "Performance" begin
    seq = Sequence{Int}(rand(1:100, 1000), 100)
    
    # Indexing should be fast and non-allocating
    @test @allocated(seq[500]) == 0
    
    # Shifting should be reasonably fast
    t = @elapsed shift(seq)
    @test t < 0.001  # Should be sub-millisecond
end
```

## Success Criteria

- [ ] All public Sequence functions pass `@inferred` tests
- [ ] No `Any` types in `@code_warntype` output
- [ ] Performance benchmarks show no regression
- [ ] Comprehensive test coverage for type stability
- [ ] Documentation updated with performance guarantees

## Related Issues

- Impacts performance of KneadingSequence operations
- Critical for HubbardTree construction efficiency
- Affects AngledInternalAddress calculations

## References

- `src/Sequences.jl` (full implementation)
- Julia Performance Tips documentation
- Type stability best practices in Julia manual