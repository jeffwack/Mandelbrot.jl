# Mandelbrot.jl Development Roadmap - 2025-07-23

## Executive Summary

This roadmap analyzes the current state of Mandelbrot.jl v0.3.0 and proposes development directions for enhancing the package's capabilities in complex quadratic dynamics visualization and exploration. The analysis covers current implementation strengths, identified issues, and strategic recommendations for future development.

## Current Package Analysis

### Core Architecture Overview

**Package Structure** (`src/Mandelbrot.jl:3-13`):
- **Foundational Types**: `BinaryExpansion`, `KneadingSequence`, `InternalAddress` 
- **Tree Structures**: `HubbardTree`, `AngledInternalAddress`, `OrientedHubbardTree`
- **Snowballing Struct**: `HyperbolicComponent`
- **Visualization**: `treeplot`, `spiderplot` functions

**Dependencies** (`Project.toml:6-8`):
- `IterTools` - iteration utilities
- `Primes` - mathematical operations
- `GLMakie`, `Colors`, `ColorSchemes` - visualization extension (move to main package?) <------

### Mathematical Implementation Status

#### ✅ **Fully Implemented Components**

1. **Sequence Framework** (`src/Sequences.jl`) <----------- (move out into dedicated package?)
   - **Core Innovation**: Automatic period reduction with prime factorization (`src/Sequences.jl:16-24`) 
   - **Smart Constructor**: Ensures all sequences in reduced form (`src/Sequences.jl:10-37`) <-------
   - **Performance**: Type-stable with hash support for dictionary keys (is this actually type stable? How can we check?) <-------------

2. **Hubbard Tree Construction** (`src/HubbardTrees.jl`)
   - **Algorithm**: Triod-based tree building (`src/HubbardTrees.jl:82-130`) (let's write some tests for trees) <-----------------------
   - **Entry Point**: `HubbardTree(K::KneadingSequence)` at `src/HubbardTrees.jl:18-33`
   - **Mathematical Rigor**: Based on [Bruin, Kafll, Schleicher paper](https://eudml.org/doc/283172) (I want to use DocumenterCitations.jl to make a solid bibliography for this package)

3. **Angled Internal Addresses** (`src/angledoubling.jl`)
   - **Complete Implementation**: Address generation, angle calculation, admissibility checking
   - **Key Functions**: 
     - `AngledInternalAddress(theta)` at `src/angledoubling.jl:183-200`
     - `admissible()` validation at `src/angledoubling.jl:141, 163, 172`
     - `bifurcate()` for tree navigation at `src/angledoubling.jl:222-227`

#### ⚠️ **Issues Requiring Attention**

1. **Spider Algorithm Convergence** (`src/spidermap.jl`)
   - **Issue**: Periodic case handling incomplete (`src/spidermap.jl:97`)
   - **Issue**: Fixed iteration count instead of tolerance-based convergence (`src/spidermap.jl:174`)
   - **Issue**: Correctness! Legs may intersect, need to test for necessary subdivision (lets make plans to tackle these) <------------------------

2. **Graph Infrastructure Gaps** (`src/Graphs.jl:1`)
   - **Issue**: Comment indicates incomplete implementation (what comment?) <-----------
   - **Current State**: Basic adjacency operations exist but may need enhancement
   - **Impact**: Limited graph manipulation capabilities

3. **Interactive Features** (`sandbox/apps/Phonebook.jl:95`)
   - **Missing**: Custom tooltips for better user experience
   - **Current**: Basic radial wedge selection interface exists (I think I will depreciate this idea in favor of the command-line ranger style interface.) <---------------------------

### Visualization Capabilities

**Current Strengths**:
- **Mathematical Accuracy**: Sophisticated node coloring based on binary expansions (`ext/GLMakieExt/showtree.jl:14-31`)
- **Tree Visualization**: Complete implementation in `treeplot()` (`ext/GLMakieExt/showtree.jl:82-84`)
- **Interactive Prototype**: Wedge-based address selection (`sandbox/apps/Phonebook.jl:23-44`)

**Identified Limitations**:
- No web-based interface
- Limited scalability for large datasets
- No CLI navigation tools

## Proposed UI and Graphical Enhancements

### 1. Ranger-Like CLI Interface

**Concept**: File manager-style navigation through angled internal address space

**Core Navigation Interface**:
```
┌─────────────────────────────────────────────────────────────────────────────┐
│ Mandelbrot Address Navigator v0.3.0          [1]─1/2─>[2]─1/3─>[6]          │
├─────────────────────────────────────────────────────────────────────────────┤
│ Current: 1─1/2─>2─1/3─>6─2/5─>12              Children: 8 branches          │
│                                                                             │
│  ●  [24]    ─ 1/13 ─  (period 24, 12 angles)    ← cursor                  │
│     [26]    ─ 1/14 ─  (period 26, 13 angles)                              │
│     [28]    ─ 1/15 ─  (period 28, 14 angles)                              │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ j/k: down/up  h/l: back/forward  g: goto  /: search  v: visualize  q: quit  │
└─────────────────────────────────────────────────────────────────────────────┤
```

**Implementation Strategy**:
```julia
# Leverage existing functions for CLI backend
mutable struct AddressNavigator
    current_address::AngledInternalAddress
    cursor_position::Int
    history_stack::Vector{AngledInternalAddress}
end

function generate_children(aia::AngledInternalAddress)
    # Use existing newdenominator() from src/angledoubling.jl:285
    # Apply admissible() validation from src/angledoubling.jl:141
    # Return sorted list of valid child addresses
end

function visualize_current!(nav::AddressNavigator)
    # Integrate with existing treeplot() from ext/GLMakieExt/showtree.jl:82
    theta = compute_representative_angle(nav.current_address)
    return treeplot(theta)
end
```

### 2. Package Integration Analysis

#### **Bonito.jl - Web Application Framework**

**Benefits**:
- **Interactive Web Interface**: Transform CLI into web-based explorer
- **Mathematical Visualization**: Proven with ocean simulations, FitzHugh-Nagumo models
- **Offline Export**: Static HTML generation for sharing
- **Widget Integration**: Interactive parameter controls

**Integration Approach**:
```julia
# Web-based address navigator
function bonito_address_explorer()
    address = Observable(AngledInternalAddress([1], []))
    
    # Interactive tree visualization
    tree_plot = map(address) do addr
        theta = compute_representative_angle(addr)
        return treeplot(theta)
    end
    
    # Navigation controls
    nav_buttons = create_navigation_widget(address)
    
    return App() do session
        return DOM.div(nav_buttons, tree_plot)
    end
end
```

**Challenges**:
- Learning curve for Hyperscript HTML generation
- Potential performance issues with complex mathematical visualizations
- Additional dependency management

**Recommendation**: **High Priority** - Excellent fit for interactive mathematical exploration

#### **AbstractTrees.jl - Tree Data Structure Interface**

**Current Implementation Gap Analysis**:

Your custom graph code (`src/Graphs.jl`) provides:
- Basic adjacency operations (`adjlist`, `addto`, `addbetween`)
- Component analysis (`component`, `globalarms`)
- Node manipulation (`removenode`)

**AbstractTrees.jl Advantages**:
- **Standardized Interface**: Implement `children()` for `HubbardTree`
- **Performance**: Type-stable traversal with compile-time optimization
- **Ecosystem**: Integrates with Julia tree algorithms

**Migration Strategy**:
```julia
# Current: Custom HubbardTree with Dict adjacency
struct HubbardTree <: AbstractHubbardTree
    adj::Dict{KneadingSequence,Set{KneadingSequence}}
    criticalpoint::KneadingSequence
end

# Proposed: AbstractTrees.jl integration
AbstractTrees.children(ht::HubbardTree) = collect(ht.adj[ht.criticalpoint])
AbstractTrees.nodevalue(seq::KneadingSequence) = seq

# Benefit: Standard tree algorithms become available
for node in PreOrderDFS(hubbard_tree)
    # Process nodes with standard traversal
end
```

**Challenges**:
- **Migration Effort**: Need to refactor existing graph operations
- **Interface Mismatch**: Your trees have bidirectional edges, AbstractTrees assumes directed
- **Custom Logic**: Tree construction algorithm (`iteratetriod`) may not map cleanly

**Recommendation**: **Medium Priority** - Beneficial long-term but requires significant refactoring (ok, let's ditch that. I think it is fun to have re-implemented graphs) <------------

#### **InteractiveViz.jl - Large Dataset Visualization**

**Perfect Match for Mandelbrot Exploration**:
- **Fractal-Specific Examples**: Repository demonstrates Mandelbrot/Julia set visualization
- **Dynamic Resolution**: Generates detail on-demand during zoom
- **Large-Scale Performance**: Handles millions of points smoothly (Here's another major feature to add: perturbative computation of the mandelbrot escape time image. We will perform the spider algorithm on legs with arbitrary precision feet, and use this as a 'core orbit' to perform perturbation expansions on. Then rendering the rest of the screen can be done with floating point arithmetic.) <-------------------------

**Integration Opportunities**:
```julia
# Dynamic Mandelbrot set exploration
function mandelbrot_datasource(region::ComplexRegion, resolution::Int)
    # Generate escape-time data on demand
    return InteractiveViz.sample(region, resolution) do c
        return mandelbrot_escape_time(c)
    end
end

# Combined with address navigation
function explore_hyperbolic_component(aia::AngledInternalAddress)
    parameter = compute_parameter(aia)
    region = local_parameter_region(parameter)
    
    return InteractiveViz.plot(mandelbrot_datasource(region, 1000))
end
```

**Benefits**:
- **Seamless Zoom**: Explore from overview to individual parameter values
- **Performance**: Maintains responsivity with complex calculations
- **Integration**: Built on Makie (same as your current GLMakie extension)

**Challenges**:
- **API Complexity**: Learning the DataSource abstraction
- **Computational Load**: Need efficient algorithms for on-demand generation
- **Version Compatibility**: API changed significantly in v0.4

**Recommendation**: **High Priority** - Excellent match for fractal exploration needs

## Strategic Development Priorities

### **Phase 1: Core Algorithm Fixes** (Immediate - 1-2 months)

1. **Spider Algorithm Robustness**
   - Implement tolerance-based convergence (`src/spidermap.jl:174`)
   - Fix periodic case handling (`src/spidermap.jl:97`)
   - Add error handling and diagnostics

2. **Graph Infrastructure Completion**
   - Complete missing functionality in `src/Graphs.jl:1`
   - Add comprehensive tests for graph operations
   - Document graph manipulation APIs

### **Phase 2: UI Enhancement** (3-6 months)

1. **CLI Interface Development**
   - Implement ranger-like address navigator
   - Add search and filtering capabilities
   - Integrate with existing visualization functions

2. **Bonito.jl Web Interface**
   - Create interactive web-based explorer
   - Add parameter space navigation
   - Implement sharing and export features

### **Phase 3: Performance and Scale** (6-12 months)

1. **InteractiveViz.jl Integration**
   - Implement dynamic Mandelbrot set rendering
   - Add multi-scale parameter space exploration
   - Optimize computational algorithms for on-demand generation

2. **AbstractTrees.jl Migration** (Optional)
   - Evaluate migration benefits vs. effort
   - Consider hybrid approach using both systems
   - Implement if clear performance gains identified

### **Phase 4: Advanced Features** (Future)

1. **Advanced Navigation**
   - Bookmark system for interesting addresses
   - Address comparison tools
   - Export capabilities (JSON, LaTeX, images)

2. **Educational Features**
   - Interactive tutorials
   - Algorithm visualization
   - Mathematical background integration

## Technical Architecture Recommendations

### **Modular Structure Enhancement**
```
Mandelbrot.jl/
├── Core/           # Current src/ content - mathematical algorithms
├── CLI/            # Ranger-like interface implementation  
├── Web/           # Bonito.jl web interface
├── Interactive/   # InteractiveViz.jl integration
└── Extensions/    # Current GLMakie extension + new features
```

### **API Design Principles**
1. **Backward Compatibility**: Maintain existing `treeplot(theta::Rational)` interface
2. **Progressive Enhancement**: Add features without breaking existing code
3. **Flexible Backends**: Support both GLMakie and web-based visualization
4. **Mathematical Precision**: Preserve exact rational arithmetic throughout

## Conclusion

Mandelbrot.jl has a solid mathematical foundation with sophisticated algorithms for complex quadratic dynamics. The proposed enhancements would transform it from a research tool into a comprehensive exploration platform while maintaining mathematical rigor.

**Key Strengths to Preserve**:
- Exact rational arithmetic in address calculations
- Mathematically rigorous tree construction algorithms
- Clean separation between mathematical logic and visualization

**Strategic Focus Areas**:
- **Immediate**: Fix known algorithm issues for reliability
- **Short-term**: Enhance user experience with CLI and web interfaces  
- **Long-term**: Scale to handle large-scale exploration and visualization

The combination of Bonito.jl for web interfaces and InteractiveViz.jl for dynamic visualization provides a powerful foundation for creating an industry-leading tool for exploring the Mandelbrot set's combinatorial structure.

---

*Generated by Claude Code and Editied by Jeff Wack- Analysis completed on 2025-07-24*
