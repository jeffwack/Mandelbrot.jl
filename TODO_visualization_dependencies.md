# TODO: Move Visualization Dependencies to Main Package

**Priority**: High  
**Location**: `Project.toml:20` - GLMakie, Colors, ColorSchemes extension  
**Current Status**: Visualization features in `ext/GLMakieExt/`

## Problem Statement

Currently, GLMakie, Colors, and ColorSchemes are weakdeps with extension support. The question is whether these should be moved to main package dependencies for easier access and development.

## Goal

Determine the best dependency structure for visualization components and implement the chosen approach.

## Analysis Required

### Current Extension Structure
```toml
[weakdeps]
ColorSchemes = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
GLMakie = "e9467ef8-e4e7-5192-8a1a-b1aee30e663a"

[extensions]
GLMakieExt = ["GLMakie","Colors","ColorSchemes"]
```

### Files in Extension
- `ext/GLMakieExt/GLMakieExt.jl` - Extension entry point
- `ext/GLMakieExt/showtree.jl` - Tree plotting functions
- `ext/GLMakieExt/mandelbrotset.jl` - Mandelbrot set rendering
- `ext/GLMakieExt/showrays.jl` - External ray visualization
- Other visualization utilities

## Options to Evaluate

### Option 1: Keep as Extension (Current)
**Pros**:
- Lighter core package
- Users can choose visualization backend
- Follows Julia ecosystem best practices
- No forced heavy dependencies

**Cons**:
- More complex development workflow
- Requires `using GLMakie` before visualization functions work
- Extension loading can be confusing for users

### Option 2: Move to Main Dependencies
**Pros**:
- Simpler user experience - visualization "just works"
- Easier development and testing
- No extension loading complexity
- All features immediately available

**Cons**:
- Heavy dependencies for users who only want mathematical functions
- Larger package size
- Goes against Julia ecosystem trends

### Option 3: Hybrid Approach
**Pros**:
- Keep extension but add convenience functions
- Provide clear user guidance
- Maintain flexibility

**Cons**:
- Still requires understanding extensions

## Recommended Approach

**Keep Extension Structure** but improve user experience:

1. **Better Documentation**: Clear setup instructions
2. **Convenience Functions**: Helper to load visualization
3. **Testing Integration**: Ensure CI tests extension properly

## Implementation Plan

### Phase 1: Investigation (1 commit)
- [ ] Analyze current extension usage patterns
- [ ] Check what other packages in ecosystem do
- [ ] Review user experience with current setup

### Phase 2: Enhancement (2-3 commits)
- [ ] Add convenience loader function:
  ```julia
  function enable_visualization()
      @eval using GLMakie, Colors, ColorSchemes
      @info "Visualization features enabled. Try treeplot(1//3)"
  end
  ```
- [ ] Improve documentation in README
- [ ] Add extension tests to CI

### Phase 3: Documentation (1 commit)
- [ ] Update docstrings to mention visualization requirements
- [ ] Add examples showing extension loading
- [ ] Create troubleshooting guide

## Success Criteria

- [ ] Clear user onboarding for visualization features
- [ ] Comprehensive test coverage for extension
- [ ] Documentation clarity improved
- [ ] Development workflow streamlined

## Related Issues

- Consider impact on CLI interface development
- Ensure compatibility with future Bonito.jl integration
- Maintain performance for mathematical-only users

## References

- `Project.toml` lines 10-16 (dependencies structure)
- `ext/GLMakieExt/` directory (current implementation)
- Julia Package Extensions documentation