# Testing and Documentation System

## Structure

Every `.jl` file in `test/` (except `runtests.jl`) is a Literate.jl source file. Each file serves two purposes:

1. **As a test**: `runtests.jl` auto-discovers and includes every other `.jl` file in `test/`, wrapping each in a `@testset` named after the file.
2. **As a docs page**: `docs/make.jl` processes the same files with `Literate.markdown`, generating pages under `docs/src/generated/`. These appear in the "Tests" section of the docs.

Lines starting with `#` become markdown exposition in the generated docs. Code and `@test` assertions appear as executable code blocks.

## Adding a new test file

Create a new `.jl` file in `test/`. It will be automatically picked up by both the test runner and the docs build. No changes to `runtests.jl` or `docs/make.jl` are needed.

## Running tests

```
] test
```

Tests have no plotting dependencies. Only `Mandelbrot` and `Test` are required.

## Plots in test files

Plots can be added as exposition for the Literate-generated docs pages using `@example` blocks inside Literate comments. These blocks are ignored by the test runner (they are just comments) but are executed by Documenter during the docs build, where `CairoMakie` and `BrotViz` are available.

```julia
# ```@example filename
# using CairoMakie, BrotViz, Mandelbrot
# kneadingtable([1//3, 1//7])
# ```
```

## Building docs

Full local build with live reload:

```julia
include("docs/serve.jl")
```

This calls `servedocs` with `skip_dir="docs/src/generated"` to avoid a rebuild loop from Literate's generated output.

Targeted build of a single file to HTML (no Documenter required):

```julia
using Literate
Literate.html("test/testinternaladdress.jl", "output/")
```
