# TODO: Extract Sequence Framework to Dedicated Package

**Priority**: Low  
**Location**: `ROADMAP.md:26` - Sequence Framework as separate package  
**Current Status**: Integrated in `src/Sequences.jl`, potential for independent package

## Problem Statement

The Sequence framework (`src/Sequences.jl`) is a sophisticated, general-purpose implementation for handling eventually periodic sequences. The question is whether this functionality is valuable enough to warrant extraction into its own Julia package.

## Goal

Evaluate whether to extract the sequence framework into a standalone package and, if beneficial, plan the extraction process.

## Current Sequence Framework Analysis

### Core Functionality (`src/Sequences.jl`)

#### Sophisticated Features
1. **Automatic Period Reduction** (`lines 16-24`):
   - Uses prime factorization via `divisors()` from Primes.jl
   - Detects minimal period automatically 
   - Handles complex nested periodicity

2. **Smart Constructor** (`lines 10-37`):
   - Ensures all sequences are in reduced form
   - Handles preperiodic sequences correctly
   - Mathematically rigorous implementation

3. **Type-Stable Operations**:
   - Efficient indexing with `mod1` arithmetic
   - Hash support for dictionary keys
   - Clean `show()` implementation with mathematical notation

4. **Mathematical Operations**:
   - `shift()` and `shiftby()` for sequence manipulation
   - `prepend()` for sequence extension
   - `orbit()` functions for dynamical systems

### Current Usage in Mandelbrot.jl

1. **KneadingSequence** (`src/angledoubling.jl:46`):
   ```julia
   const KneadingSequence = Sequence{KneadingSymbol}
   ```

2. **BinaryExpansion** (`src/angledoubling.jl:349`):
   ```julia
   const BinaryExpansion = Sequence{Digit{2}}
   ```

3. **Tree Construction** (`src/HubbardTrees.jl`):
   - Used throughout for representing tree nodes
   - Critical for tree manipulation algorithms

## Evaluation Criteria

### Arguments FOR Extraction

#### Broader Applicability
```julia
# The framework could be useful for:

# Number theory - periodic continued fractions
cf = Sequence{Rational}([1, 2, 2, 1, 2], 1)  # √2 = [1; 2, 2, 2, ...]

# Music theory - rhythmic patterns  
rhythm = Sequence{Symbol}([:beat, :rest, :beat], 0)

# Cryptography - periodic keystreams
keystream = Sequence{Bool}([true, false, true, false], 2)

# Signal processing - periodic waveforms
signal = Sequence{Float64}([1.0, 0.0, -1.0, 0.0], 0)

# Combinatorics - periodic sequences in OEIS
fibonacci_mod_7 = Sequence{Int}([0, 1, 1, 2, 3, 5, 1, 6, 0, 6, 6, 5, 4, 2, 6, 1], 0)
```

#### Mathematical Rigor
- The automatic period reduction is non-trivial
- Handles edge cases that many implementations miss
- Type-stable performance is rare in this domain
- Well-tested through Mandelbrot.jl usage

#### Clean API
- Simple constructor: `Sequence{T}(items, preperiod)`
- Intuitive indexing: `seq[n]` works for any `n`
- Mathematical notation in `show()`: `|A B|` for periodic part

### Arguments AGAINST Extraction

#### Limited Audience
- Very specialized use case
- May not have enough users to justify maintenance
- Mathematical packages often have smaller communities

#### Maintenance Overhead
- Separate package requires independent CI/testing
- Documentation overhead
- Version compatibility management
- Issue tracking and support

#### Integration Complexity
- Would add dependency management complexity to Mandelbrot.jl
- Breaking changes in sequence package could affect Mandelbrot.jl
- Less flexibility for Mandelbrot-specific optimizations

## Investigation Tasks

### Phase 1: Market Research (Analysis Only)

#### Survey Existing Packages
- [ ] **Search JuliaHub** for similar sequence/period detection packages
- [ ] **Review mathematical domains** that might benefit:
  - Number theory packages
  - Signal processing packages  
  - Combinatorics packages
  - Music analysis packages

#### Assess Demand
- [ ] **Check discourse.julialang.org** for related questions
- [ ] **Review OEIS integration packages** 
- [ ] **Look at academic papers** citing periodic sequence algorithms

#### Compare Implementation Quality
```julia
# Benchmark against naive implementations
function naive_sequence_indexing(items, preperiod, period, index)
    if index <= preperiod
        return items[index]
    else
        periodic_part = items[(preperiod+1):end]
        return periodic_part[mod1(index - preperiod, length(periodic_part))]
    end
end

# Performance comparison
seq = Sequence{Int}([1,2,3,4,5,4,5], 3)  # [1,2,3,|4,5|]
@benchmark seq[1000]                      # Type-stable version
@benchmark naive_sequence_indexing([1,2,3,4,5,4,5], 3, 2, 1000)  # Naive version
```

### Phase 2: Standalone Package Design (If Proceeding)

#### Package Structure
```
PeriodicSequences.jl/
├── src/
│   ├── PeriodicSequences.jl    # Main module
│   ├── sequence.jl             # Core Sequence type
│   ├── operations.jl           # shift, prepend, etc.
│   └── algorithms.jl           # period detection, orbit analysis
├── test/
│   ├── runtests.jl
│   ├── sequence_tests.jl
│   ├── operations_tests.jl
│   └── benchmarks.jl
├── docs/
│   ├── make.jl
│   └── src/
│       ├── index.md
│       ├── manual.md
│       └── examples.md
└── examples/
    ├── number_theory.jl
    ├── signal_processing.jl
    └── combinatorics.jl
```

#### Enhanced API for General Use
```julia
module PeriodicSequences

export Sequence, period, preperiod, shift, prepend, orbit, detect_period

# Enhanced constructor with period detection
function Sequence(items::Vector{T}; detect_period::Bool=true) where T
    if detect_period
        return auto_detect_sequence(items)
    else
        return Sequence{T}(items, 0)  # Assume purely periodic
    end
end

# Period detection from raw data
function detect_period(data::Vector{T}, max_period::Int=length(data)÷2) where T
    for p in 1:max_period
        if is_periodic_with_period(data, p)
            return p
        end
    end
    return length(data)  # No period found
end

# Sequence arithmetic
Base.:+(s1::Sequence, s2::Sequence) = sequence_add(s1, s2)
Base.:*(s::Sequence, n::Integer) = sequence_repeat(s, n)

# Conversion utilities
Base.Vector(s::Sequence, length::Int) = [s[i] for i in 1:length]
```

### Phase 3: Migration Planning (If Proceeding)

#### Extraction Process
1. **Create new package repository**
2. **Copy sequence implementation with enhancements**
3. **Add comprehensive documentation and examples**
4. **Set up CI/testing infrastructure**
5. **Submit to Julia package registry**
6. **Update Mandelbrot.jl to use new dependency**

#### Mandelbrot.jl Migration
```julia
# Before (current)
using IterTools, Primes
include("Sequences.jl")

# After (with extracted package)
using IterTools, Primes, PeriodicSequences
const KneadingSequence = Sequence{KneadingSymbol}
const BinaryExpansion = Sequence{Digit{2}}
```

## Decision Framework

### Quantitative Criteria
- **Potential users**: > 10 packages could benefit
- **Performance benefit**: > 2x speedup over naive implementations  
- **Code reuse**: > 500 lines of mathematical code
- **Maintenance cost**: < 4 hours/month estimated

### Qualitative Criteria
- **Mathematical significance**: Is the algorithm non-trivial?
- **API quality**: Is the interface clean and intuitive?
- **Documentation potential**: Can we write good tutorials?
- **Community value**: Does this fill a gap in the ecosystem?

## Recommended Decision Process

### Step 1: Community Interest Assessment
- [ ] Post on Julia Discourse about potential sequence package
- [ ] Gauge interest from number theory/signal processing communities
- [ ] Get feedback on API design

### Step 2: Implementation Quality Check  
- [ ] Complete type stability analysis (see TODO_sequence_type_stability.md)
- [ ] Benchmark against alternatives
- [ ] Ensure mathematical correctness

### Step 3: Go/No-Go Decision
Based on results from steps 1-2:

**GO** if:
- Strong community interest (>5 serious potential users)
- Implementation is demonstrably superior to alternatives
- Maintenance effort is reasonable

**NO-GO** if:
- Limited interest outside of Mandelbrot.jl
- Existing packages adequately cover the use cases
- Maintenance overhead too high

## Alternative: Enhanced Internal Package

If extraction isn't warranted, consider enhancing the internal implementation:

```julia
# Enhanced Sequences.jl for Mandelbrot.jl internal use
module Sequences

# Add more mathematical operations
export sequence_lcm, sequence_gcd, sequence_compose

# Better performance tuning
struct CachedSequence{T} <: AbstractSequence{T}
    seq::Sequence{T}
    index_cache::Dict{Int, T}
    max_cache_size::Int
end

# Domain-specific optimizations
struct KneadingSequenceOptimized <: AbstractKneadingSequence
    # Specialized for KneadingSymbol operations
end
```

## Success Criteria (If Extracting)

- [ ] Package successfully registered in Julia General registry
- [ ] At least 3 other packages adopt PeriodicSequences.jl
- [ ] Performance benchmarks show clear advantages
- [ ] Documentation receives positive community feedback
- [ ] Mandelbrot.jl migration completed without issues
- [ ] Maintenance effort remains manageable (< 2 hours/month)

## Related Issues

- Depends on sequence type stability analysis
- May affect all other Mandelbrot.jl development
- Consider timing relative to other package improvements

## References

- `src/Sequences.jl` (current implementation)
- Julia package development best practices
- Similar mathematical packages in ecosystem
- Community feedback from Julia Discourse