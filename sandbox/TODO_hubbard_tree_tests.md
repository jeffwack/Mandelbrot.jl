# TODO: Comprehensive Hubbard Tree Testing Suite

**Priority**: High  
**Location**: `src/HubbardTrees.jl:32` - Triod-based tree building algorithm  
**Current Status**: Algorithm implemented but lacks comprehensive testing

## Problem Statement

The Hubbard tree construction algorithm is mathematically sophisticated (based on Bruin, Kafll, Schleicher paper) but currently lacks comprehensive tests. This is critical infrastructure that needs thorough validation.

## Goal

Create a comprehensive test suite that validates the correctness of Hubbard tree construction, covering edge cases, mathematical properties, and algorithmic correctness.

## Mathematical Background to Test

### Core Algorithm (`src/HubbardTrees.jl:18-33`)
```julia
function HubbardTree(K::KneadingSequence)
    starK = prepend(K,KneadingSymbol('*'))
    markedpoints = copy(orbit(starK).items)
    
    H = Dict([Pair(starK,Set([K])),Pair(K,Set([starK]))])
    for point in markedpoints[3:end]
        if !(point in keys(H)) 
            H = addsequence(H,K,(starK,deepcopy(H[starK])),point)
        end
    end
    return HubbardTree(H,starK)
end
```

### Triod Algorithm (`src/HubbardTrees.jl:82-130`)
The heart of the construction - needs extensive testing for correctness.

## Test Categories Required

### 1. Basic Construction Tests
```julia
@testset "Basic Hubbard Tree Construction" begin
    # Simple cases
    @testset "Period 1 - Fixed Point" begin
        K = KneadingSequence([KneadingSymbol('A')], 0)
        H = HubbardTree(K)
        @test length(vertices(H)) >= 2  # At least * and A
        @test criticalpoint(H) in vertices(H)
    end
    
    @testset "Period 2 - Basic Binary" begin
        K = KneadingSequence([KneadingSymbol('A'), KneadingSymbol('B')], 0)
        H = HubbardTree(K)
        # Test properties specific to period-2 case
    end
end
```

### 2. Mathematical Property Tests
```julia
@testset "Tree Properties" begin
    @testset "Connectedness" begin
        # Every Hubbard tree should be connected
        for K in test_kneading_sequences()
            H = HubbardTree(K)
            @test is_connected(H)
        end
    end
    
    @testset "Critical Point" begin
        # Critical point should be in every tree
        for K in test_kneading_sequences()
            H = HubbardTree(K)
            cp = criticalpoint(H)
            @test cp in vertices(H)
            @test cp.items[1] == KneadingSymbol('*')
        end
    end
    
    @testset "Tree Structure" begin
        # Should be acyclic (true tree)
        for K in test_kneading_sequences()
            H = HubbardTree(K)
            @test is_acyclic(H)
        end
    end
end
```

### 3. Triod Algorithm Tests
```julia
@testset "Triod Algorithm" begin
    @testset "Triod Classification" begin
        # Test the three outcomes: "flat", "branched"
        K = KneadingSequence([KneadingSymbol('A')], 0)
        
        # Known triod configurations
        triod1 = (somesequence1, somesequence2, somesequence3)
        result, point = iteratetriod(K, triod1)
        @test result in ["flat", "branched"]
    end
    
    @testset "Majority Vote" begin
        # Test majorityvote function
        arms = (seq_A, seq_B, seq_A)  # A should win
        @test majorityvote(arms) == seq_A.items[1]
    end
end
```

### 4. Integration Tests
```julia
@testset "Integration with Other Components" begin
    @testset "From Internal Address" begin
        # Test constructor from InternalAddress
        intadd = InternalAddress([1, 2, 4])
        H = HubbardTree(intadd)
        @test H isa HubbardTree
        @test length(vertices(H)) > 0
    end
    
    @testset "Tree Extension" begin
        # Test extend function
        K = KneadingSequence([KneadingSymbol('A')], 0)
        H = HubbardTree(K)
        new_seq = Sequence([KneadingSymbol('B')], 0)
        H_extended = extend(H, new_seq)
        @test length(vertices(H_extended)) >= length(vertices(H))
    end
end
```

### 5. Edge Cases and Error Handling
```julia
@testset "Edge Cases" begin
    @testset "Empty Sequences" begin
        # How should algorithm handle degenerate cases?
        @test_throws ArgumentError HubbardTree(empty_sequence)
    end
    
    @testset "Very Long Periods" begin
        # Test performance and correctness with long sequences
        long_K = generate_long_kneading_sequence(100)
        H = HubbardTree(long_K)
        @test H isa HubbardTree
    end
    
    @testset "Preperiodic Cases" begin
        # Test with non-zero preperiod
        K = KneadingSequence([KneadingSymbol('A'), KneadingSymbol('B'), KneadingSymbol('A')], 1)
        H = HubbardTree(K)
        @test H isa HubbardTree
    end
end
```

### 6. Reference Cases
```julia
@testset "Known Reference Cases" begin
    # Test against hand-computed examples from literature
    @testset "Main Cardioid (Period 1)" begin
        K = main_cardioid_kneading()
        H = HubbardTree(K)
        # Verify specific properties of this well-known case
    end
    
    @testset "Period-2 Bulb" begin
        K = period_2_bulb_kneading()
        H = HubbardTree(K)
        # Verify against known structure
    end
end
```

## Test Infrastructure Needed

### Helper Functions
```julia
# Generate test kneading sequences
function test_kneading_sequences()
    return [
        KneadingSequence([KneadingSymbol('A')], 0),
        KneadingSequence([KneadingSymbol('B')], 0),
        KneadingSequence([KneadingSymbol('A'), KneadingSymbol('B')], 0),
        # ... more cases
    ]
end

# Tree property checks
function is_connected(H::HubbardTree)
    # Implement graph connectivity check
end

function is_acyclic(H::HubbardTree)
    # Implement cycle detection
end
```

### Visual Validation
```julia
@testset "Visual Validation" begin
    # Generate plots for manual inspection
    for (name, K) in named_test_cases()
        H = HubbardTree(K)
        # Save tree plot for manual verification
        # (Don't include in CI, but useful for development)
        if get(ENV, "GENERATE_TEST_PLOTS", "false") == "true"
            save_tree_plot(H, "test_tree_$name.png")
        end
    end
end
```

## Implementation Plan

### Phase 1: Basic Test Infrastructure (1 commit)
- [ ] Create `test/hubbardtrees.jl` test file
- [ ] Implement basic construction tests
- [ ] Add helper functions for tree properties
- [ ] Test with simple, known cases

### Phase 2: Mathematical Properties (1 commit)
- [ ] Implement connectivity checking
- [ ] Add acyclicity tests
- [ ] Verify critical point properties
- [ ] Test tree structural properties

### Phase 3: Algorithm-Specific Tests (1 commit)
- [ ] Test triod algorithm components
- [ ] Verify addsequence function
- [ ] Test majority vote logic
- [ ] Add edge case handling

### Phase 4: Integration and Performance (1 commit)
- [ ] Test integration with other components
- [ ] Add performance benchmarks
- [ ] Test with various sequence types
- [ ] Add regression tests

## Success Criteria

- [ ] All basic construction cases pass
- [ ] Mathematical properties verified for test cases
- [ ] Triod algorithm components thoroughly tested
- [ ] Edge cases handled appropriately
- [ ] Performance acceptable for reasonable input sizes
- [ ] Test coverage > 90% for HubbardTrees.jl
- [ ] CI integration working

## Related Issues

- Depends on Sequence framework tests
- Impacts visualization testing
- Required for spider algorithm validation

## References

- `src/HubbardTrees.jl` (implementation)
- [Bruin, Kafll, Schleicher paper](https://eudml.org/doc/283172)
- `test/runtests.jl` (current test structure)