# TODO: Implement DocumenterCitations.jl Bibliography System

**Priority**: Medium  
**Location**: `ROADMAP.md:34` - Mathematical rigor with proper citations  
**Current Status**: Hard-coded URLs in comments, no formal bibliography

## Problem Statement

The package references important mathematical papers (like Bruin, Kafll, Schleicher) but lacks a formal bibliography system. For a mathematical package, proper citation management is essential for credibility and scholarly use.

## Goal

Implement a comprehensive bibliography system using DocumenterCitations.jl for proper academic reference management.

## Current Citation Issues

### Existing References Found
1. **Bruin, Kafll, Schleicher paper**: `src/HubbardTrees.jl:1-3`
   ```julia
   #Algorithms from https://eudml.org/doc/283172
   #Existence of quadratic Hubbard trees
   #Henk Bruin, Alexandra Kafll, Dierk Schleicher
   ```

2. **Spider Algorithm**: Referenced in README.md:8
   ```markdown
   [Read about the spider algorithm.](https://pi.math.cornell.edu/~hubbard/SpidersFinal.pdf)
   ```

3. **Internal Addresses**: README.md:9
   ```markdown
   [Read about internal addresses.](https://arxiv.org/abs/math/9411238)
   ```

4. **Hubbard Trees**: README.md:10
   ```markdown
   [Read about Hubbard trees.](https://www.mat.univie.ac.at/~bruin/papers/bkafsch.pdf)
   ```

## Implementation Plan

### Phase 1: Bibliography Setup (1 commit)

#### Add DocumenterCitations.jl to docs
```toml
# docs/Project.toml
[deps]
Documenter = "e30172f5-a6a5-5a46-863b-614d45cd2de4"
DocumenterCitations = "daee34ce-89f3-4625-b898-19384cb65244"
```

#### Create bibliography file
```bibtex
# docs/src/refs.bib
@article{bruin2008existence,
  title={Existence of quadratic Hubbard trees},
  author={Bruin, Henk and Kaffl, Alexandra and Schleicher, Dierk},
  journal={Fundamenta Mathematicae},
  volume={202},
  number={3},
  pages={251--279},
  year={2008},
  doi={10.4064/fm202-3-4},
  url={https://eudml.org/doc/283172}
}

@article{hubbard1985spider,
  title={The spider algorithm},
  author={Hubbard, John H and Schleicher, Dierk},
  url={https://pi.math.cornell.edu/~hubbard/SpidersFinal.pdf},
  year={1985}
}

@article{poirier1993internal,
  title={On postcritically finite polynomials, part two: Hubbard trees},
  author={Poirier, Alfredo},
  journal={arXiv preprint math/9411238},
  year={1993},
  url={https://arxiv.org/abs/math/9411238}
}

@article{bruin2008kneading,
  title={Kneading sequences and Hubbard trees},
  author={Bruin, Henk and others},
  url={https://www.mat.univie.ac.at/~bruin/papers/bkafsch.pdf},
  year={2008}
}
```

### Phase 2: Documentation Integration (1 commit)

#### Update docs/make.jl
```julia
using Documenter, DocumenterCitations, Mandelbrot

bib = CitationBibliography(joinpath(@__DIR__, "src", "refs.bib"))

makedocs(
    modules=[Mandelbrot],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
        "Sequences" => "sequences.md",
        "Hubbard Trees" => "hubbardtrees.md",
        "Spider Algorithm" => "spider.md",
        "Bibliography" => "bibliography.md"
    ],
    plugins=[bib],
    sitename="Mandelbrot.jl",
    authors="Jeffrey Wack"
)
```

#### Create bibliography page
```markdown
# docs/src/bibliography.md
# Bibliography

## References

```@bibliography
```

### Phase 3: Code Documentation Updates (2-3 commits)

#### Update function docstrings with citations
```julia
"""
    HubbardTree(K::KneadingSequence)

Creates a topological Hubbard tree from the given kneading sequence using the 
triod algorithm described in [bruin2008existence](@cite).

The algorithm constructs the tree by iteratively adding sequences from the 
critical orbit using the triod map to determine correct positioning.

# References
- [bruin2008existence](@cite): Original algorithm description
"""
function HubbardTree(K::KneadingSequence)
    # ... existing implementation
end
```

#### Update module documentation
```julia
"""
# Mandelbrot.jl

This package implements several algorithms related to complex quadratic dynamics:

- **Spider Algorithm**: Calculates hyperbolic component centers from external angles [hubbard1985spider](@cite)
- **Internal Addresses**: Describes paths to hyperbolic components [poirier1993internal](@cite)  
- **Hubbard Trees**: Combinatorial description from kneading sequences [bruin2008kneading](@cite)

## Mathematical Background

The algorithms implemented here are based on the theory of complex quadratic dynamics,
particularly the work on...

## References

```@bibliography
```
"""
module Mandelbrot
```

### Phase 4: Comprehensive Documentation (1-2 commits)

#### Create detailed algorithm pages
```markdown
# docs/src/spider.md
# Spider Algorithm

The spider algorithm [hubbard1985spider](@cite) computes the center of a hyperbolic 
component of the Mandelbrot set from one of its external angles.

## Mathematical Foundation

Given an external angle θ that lands at a hyperbolic component...

## Implementation

```@docs
spidermap
```

## References
```@bibliography
Pages = ["spider.md"]
```

#### Add mathematical context
```markdown
# docs/src/hubbardtrees.md  
# Hubbard Trees

Hubbard trees provide a combinatorial model for the dynamics of quadratic polynomials.
The construction algorithm follows [bruin2008existence](@cite).

## Theory

A Hubbard tree is a finite tree that models...

## Algorithm

The triod-based construction algorithm works by...

```@docs
HubbardTree
iteratetriod
```
```

## Advanced Features

### Citation Management in Comments
Replace hard-coded URLs in source code:
```julia
# Before:
#Algorithms from https://eudml.org/doc/283172
#Existence of quadratic Hubbard trees
#Henk Bruin, Alexandra Kafll, Schleicher

# After:
"""
Triod-based Hubbard tree construction algorithm.

Implementation follows the algorithm described in [bruin2008existence](@cite).
"""
```

### Cross-References
```julia
"""
    AngledInternalAddress(theta)

Computes the angled internal address for a given angle theta.

The theory of internal addresses is developed in [poirier1993internal](@cite),
with the angled variant used for orientation as described in [bruin2008kneading](@cite).

See also: [`InternalAddress`](@ref), [`HubbardTree`](@ref)
"""
```

## Success Criteria

- [ ] DocumenterCitations.jl properly integrated
- [ ] Complete bibliography with proper BibTeX entries
- [ ] All major algorithms have cited documentation
- [ ] Documentation builds without citation warnings
- [ ] Bibliography page generated correctly
- [ ] Cross-references working between algorithms
- [ ] Source code comments reference bibliography
- [ ] Academic credibility improved

## Benefits

1. **Academic Credibility**: Proper attribution of sources
2. **Reproducible Research**: Clear references for algorithms
3. **Educational Value**: Students can trace theory to sources
4. **Professional Presentation**: Publication-quality documentation
5. **Maintenance**: Centralized reference management

## Related Issues

- Enhances documentation for CLI interface users
- Important for educational use cases
- Required for any academic publication about the package

## References for Implementation

- [DocumenterCitations.jl documentation](https://documenter.juliadocs.org/stable/)
- [BibTeX format specification](http://www.bibtex.org/Format/)
- Julia documentation best practices