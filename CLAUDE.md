# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Development
```bash
# Run tests
julia --project=. test/runtests.jl

# Build documentation
julia --project=docs docs/make.jl

# Start Julia REPL with project
julia --project=.
```

### Package Management
```bash
# Activate project environment
julia --project=.

# Then in Julia REPL:
using Pkg
Pkg.instantiate()  # Install dependencies
Pkg.test()         # Run tests
```

## Code Architecture

This is a Julia package implementing algorithms for complex quadratic dynamics, specifically focused on the Mandelbrot set and related mathematical structures.

### Core Components

**Main Module Structure** (`src/Mandelbrot.jl`):
- Primary exports: `BinaryExpansion`, `KneadingSequence`, `InternalAddress`, `HubbardTree`, `AngledInternalAddress`, `OrientedHubbardTree`, `HyperbolicComponent`
- Key functions: `parameter`, `orbit`, `treeplot`, `spiderplot`

**Core Mathematical Objects**:
- **Sequences** (`src/Sequences.jl`): Implements eventually periodic sequences with preperiod and period properties
- **Kneading Sequences**: Represent symbolic dynamics of quadratic maps
- **Hubbard Trees** (`src/HubbardTrees.jl`): Topological trees from kneading sequences following Bruin-Kafll-Schleicher algorithms
- **Internal Addresses**: Combinatorial descriptions of paths in the Mandelbrot set
- **Spider Algorithm** (`src/spiderfuncs.jl`, `src/spidermap.jl`): Calculates hyperbolic component centers from external angles

**Extension System**:
- **GLMakieExt** (`ext/GLMakieExt/`): Plotting functionality using GLMakie (weak dependency)
- Provides `treeplot()` and `spiderplot()` visualizations
- Extension auto-loads when GLMakie is available

### Key Algorithms

1. **Spider Algorithm**: Calculates Mandelbrot set hyperbolic component centers from external angles
2. **Hubbard Tree Construction**: Builds combinatorial trees from kneading sequences
3. **External Ray Computation**: Calculates external angles from internal addresses
4. **Angle Doubling**: Implements doubling map operations on angles

### Dependencies

- **Core**: `IterTools`, `Primes`
- **Weak Dependencies**: `GLMakie`, `Colors`, `ColorSchemes` (for visualization)
- **Documentation**: `Documenter`, `LiveServer`

### Testing

Minimal test suite in `test/runtests.jl` - tests basic kneading sequence equality. The package appears to be primarily research-oriented with extensive sandbox examples.

### Documentation

- Uses Documenter.jl for documentation generation
- Documentation source in `docs/src/` with comprehensive mathematical explanations
- Examples and interactive content in `sandbox/` directory

### Key Entry Points

- `treeplot(theta)` where `theta` is a rational number (odd denominator) - plots Hubbard tree
- `parameter(angle, iterations)` - spider algorithm implementation
- Most functionality requires GLMakie extension to be loaded for visualization

## Julia Best Practices

This section outlines key Julia programming best practices based on the Julia manual style guide, tailored for scientific computing package development.

### Code Organization

- **Write functions, not scripts**: Functions are more reusable, testable, and clarify what steps are being done
- **Functions should take arguments**: Avoid operating on global variables
- **Design for reusability**: Aim for generic, flexible function designs that work with multiple types

### Naming Conventions

- **Modules and types**: Use capitalized camel case (`SparseArrays`, `UnitRange`, `SystemLevelHamiltonian`)
- **Functions**: Use lowercase (`maximum`, `haskey`, `concatenate`)
- **Multi-word functions**: Use underscores when needed (`feedback_reduce`)
- **Mutating functions**: Append `!` to functions that modify arguments (`push!`, `pop!`)

### Type Design and Performance

- **Avoid overly-specific types**: Prefer abstract types like `Integer` over concrete types like `Int32`
- **Let Julia specialize**: The compiler will automatically optimize generic code
- **Handle type conversions at caller level**: Don't force conversions inside functions
- **Use `Int` literals in generic code**: When writing generic numerical algorithms

### Function Design Principles

Follow Base library argument ordering:
1. Function argument
2. IO stream  
3. Input being mutated
4. Type
5. Immutable inputs

### Best Practices for Scientific Computing

- **Prefer exported methods**: Don't directly access fields of types you don't own
- **Avoid type piracy**: Don't extend types from other packages inappropriately
- **Use multiple dispatch**: Design flexible implementations that work with different types
- **Minimize type conversions**: Let Julia's type system work efficiently
- **Use proper type checking**: Use `isa` and `<:` for type checking, not `==`

### Performance Guidelines

- **Create type-generic numerical algorithms**: Design functions to work with multiple numeric types
- **Let the compiler optimize**: Trust Julia's compiler to specialize generic code
- **Avoid unnecessary static type parameters**: Don't over-constrain your functions
- **Don't expose unsafe operations**: Keep unsafe operations internal to your implementation

## Julia Documentation Best Practices

This section outlines best practices for writing clear, comprehensive documentation in Julia, based on the Julia manual and Documenter.jl guidelines.

### Docstring Structure

Every function should have a docstring following this template:

```julia
"""
    function_name(arg1[, arg2])

Concise imperative description of function purpose.

Optional detailed explanation of function behavior.

# Arguments
- `arg1`: Description of first argument
- `arg2`: Description of second argument (if needed)

# Examples
```jldoctest
julia> example_usage()
expected_output
```

See also: [`related_function1`](@ref), [`related_function2`](@ref)
"""
```

### Docstring Guidelines

- **Function signature**: Always show with 4-space indent at the top
- **One-line description**: Use imperative form ("Create", "Calculate", "Return")
- **Avoid redundant language**: Don't use "The function..." or similar
- **Use Markdown formatting**: Backticks for code, proper headers
- **Line length**: Respect 92-character limit for readability
- **Self-contained examples**: Include executable doctests that work independently

### Documentation Organization

#### Package Structure
- Create `docs/` directory in package root
- Use `docs/src/` for markdown files
- Include `docs/make.jl` for Documenter.jl configuration
- Use `DocumenterTools.generate()` to set up initial structure

#### Content Organization
- **index.md**: Main documentation page with overview
- **API sections**: Use `@docs` blocks to include function docstrings
- **Navigation**: Use `@contents` and `@index` blocks for automatic navigation
- **Cross-references**: Use `[@ref]` syntax to link between sections

### Doctests and Examples

- Use `# Examples` section with executable doctests
- Format as ` ```jldoctest ` code blocks
- Make examples mimic REPL interactions
- Avoid `rand()` for consistent test outputs
- Include realistic use cases from the domain

### Advanced Documentation Techniques

- **Generic functions**: Document both generic functions and specific methods when behavior differs
- **Type documentation**: Use `@doc` macro for flexible documentation attachment
- **Dynamic documentation**: Consider for complex parametric types
- **Module context**: Use `@meta` block to specify current module

### Documentation Configuration

Using Documenter.jl:
- Configure `makedocs()` with `sitename` and `modules`
- Control sidebar navigation with `pages` argument
- Support both light and dark theme logos in `src/assets/`
- Use LiveServer for local preview during development

### Scientific Computing Specific Guidelines

- **Mathematical notation**: Use LaTeX math mode when appropriate
- **Physical units**: Always specify units in physics/engineering contexts
- **Parameter ranges**: Document valid input ranges and constraints
- **References**: Include citations to relevant papers or algorithms
- **Performance notes**: Document computational complexity when relevant