# TODO: Ranger-Style CLI Interface Development

**Priority**: Medium  
**Location**: `ROADMAP.md:57` - Depreciate Phonebook in favor of CLI interface  
**Current Status**: Concept designed, no implementation exists

## Problem Statement

The current interactive interface (`sandbox/apps/Phonebook.jl`) uses a radial wedge selection system, but you want to replace this with a ranger-style command-line interface for navigating angled internal address space.

## Goal

Implement a full-featured CLI interface that allows intuitive navigation through the combinatorial space of angled internal addresses, similar to the ranger file manager.

## Interface Design (from Roadmap)

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

## Implementation Architecture

### Core Components

#### 1. Navigator State Management
```julia
mutable struct AddressNavigator
    current_address::AngledInternalAddress
    cursor_position::Int
    view_offset::Int
    terminal_height::Int
    history_stack::Vector{AngledInternalAddress}
    bookmarks::Dict{String, AngledInternalAddress}
end
```

#### 2. Children Generation (Leveraging Existing Code)
```julia
function generate_children(aia::AngledInternalAddress, lookahead::Int=20)
    children = AngledInternalAddress[]
    last_addr = aia.addr[end]
    
    for next_int in (last_addr + 1):(last_addr + lookahead)
        k = newdenominator(aia, next_int)  # Use existing function
        
        for numerator in 1:(k-1)
            if gcd(numerator, k) == 1
                new_addr = vcat(aia.addr, [next_int])
                new_angles = vcat(aia.angles, [numerator//k])
                
                candidate = AngledInternalAddress(new_addr, new_angles)
                
                if admissible(InternalAddress(new_addr))  # Use existing validation
                    push!(children, candidate)
                end
            end
        end
    end
    
    return sort(children, by=x->x.addr[end])
end
```

## Implementation Plan

### Phase 1: Core CLI Framework (1-2 commits)

#### Terminal Input/Output Management
```julia
using REPL.TerminalMenus  # For terminal UI functionality

function run_address_navigator()
    nav = AddressNavigator(
        AngledInternalAddress([1], []),  # Start at root
        1,  # cursor_position
        0,  # view_offset
        24, # terminal_height
        AngledInternalAddress[],  # history
        Dict{String, AngledInternalAddress}()  # bookmarks
    )
    
    # Main event loop
    while true
        clear_screen()
        draw_interface(nav)
        
        key = read_key()
        
        if handle_key_input(nav, key) == :quit
            break
        end
    end
end

function clear_screen()
    print("\033[2J\033[H")  # ANSI escape codes
end

function read_key()
    # Read single keypress without Enter
    # Platform-specific implementation needed
end
```

#### Display System
```julia
function draw_interface(nav::AddressNavigator)
    draw_header(nav)
    draw_current_path(nav)
    draw_children_list(nav)
    draw_status_bar(nav)
    draw_help_line()
end

function draw_header(nav::AddressNavigator)
    title = "Mandelbrot Address Navigator v0.3.0"
    path_summary = format_path_summary(nav.current_address)
    
    println("┌" * "─"^77 * "┐")
    println("│ $title    $path_summary │")
    println("├" * "─"^77 * "┤")
end

function draw_current_path(nav::AddressNavigator)
    path_str = format_address_path(nav.current_address)
    children_count = length(generate_children(nav.current_address))
    
    println("│ Current: $path_str    Children: $children_count branches │")
    println("│" * " "^77 * "│")
end

function draw_children_list(nav::AddressNavigator)
    children = generate_children(nav.current_address)
    visible_range = calculate_visible_range(nav, children)
    
    for (i, child) in enumerate(children[visible_range])
        cursor = (i + nav.view_offset == nav.cursor_position) ? "●" : " "
        
        addr_part = "[$(child.addr[end])]"
        angle_part = length(child.angles) > 0 ? "─ $(child.angles[end]) ─" : ""
        period = calculate_period(child)
        angles_count = count_angle_choices(child)
        info_part = "(period $period, $angles_count angles)"
        
        line = "│  $cursor  $addr_part    $angle_part  $info_part"
        println(rpad(line, 78) * "│")
    end
    
    # Fill remaining lines
    for _ in 1:(nav.terminal_height - length(visible_range) - 6)
        println("│" * " "^77 * "│")
    end
end
```

### Phase 2: Navigation Logic (1 commit)

#### Key Handler System
```julia
function handle_key_input(nav::AddressNavigator, key::Char)::Symbol
    if key == 'q'
        return :quit
    elseif key == 'j'
        navigate_down!(nav)
    elseif key == 'k'  
        navigate_up!(nav)
    elseif key == 'l' || key == '\r'  # Enter key
        navigate_forward!(nav)
    elseif key == 'h'
        navigate_back!(nav)
    elseif key == 'g'
        goto_address_prompt!(nav)
    elseif key == '/'
        search_prompt!(nav)
    elseif key == 'v'
        visualize_current!(nav)
    elseif key == 'b'
        bookmark_current!(nav)
    end
    
    return :continue
end

function navigate_forward!(nav::AddressNavigator)
    children = generate_children(nav.current_address)
    if nav.cursor_position <= length(children)
        push!(nav.history_stack, nav.current_address)
        nav.current_address = children[nav.cursor_position]
        nav.cursor_position = 1
        nav.view_offset = 0
    end
end

function navigate_back!(nav::AddressNavigator)
    if !isempty(nav.history_stack)
        nav.current_address = pop!(nav.history_stack)
        nav.cursor_position = 1
        nav.view_offset = 0
    end
end
```

### Phase 3: Advanced Features (1-2 commits)

#### Search System
```julia
function search_prompt!(nav::AddressNavigator)
    print("Search: ")
    query = readline()
    
    results = search_addresses(query)
    
    if !isempty(results)
        # Display search results in a selectable list
        selected = select_from_list(results)
        if selected !== nothing
            push!(nav.history_stack, nav.current_address)
            nav.current_address = selected
            nav.cursor_position = 1
        end
    else
        println("No results found. Press any key to continue...")
        read_key()
    end
end

function search_addresses(query::String)
    results = AngledInternalAddress[]
    
    if startswith(query, "period:")
        target_period = parse(Int, query[8:end])
        results = find_addresses_by_period(target_period)
    elseif startswith(query, "addr:")
        # Search by address pattern like "addr:1-2-4"
        results = find_addresses_by_pattern(query[6:end])
    else
        # Fuzzy search
        results = fuzzy_search_addresses(query)
    end
    
    return results
end
```

#### Visualization Integration
```julia
function visualize_current!(nav::AddressNavigator)
    try
        # Use existing treeplot functionality
        theta = compute_representative_angle(nav.current_address)
        fig = treeplot(theta)
        
        # Display plot (requires GLMakie to be loaded)
        display(fig)
        
        println("Press any key to continue...")
        read_key()
    catch e
        println("Visualization error: $e")
        println("Make sure GLMakie is loaded. Press any key to continue...")
        read_key()
    end
end
```

### Phase 4: Polish and Performance (1 commit)

#### Performance Optimizations
```julia
# Cache children generation
mutable struct NavigatorCache
    children_cache::Dict{AngledInternalAddress, Vector{AngledInternalAddress}}
    max_cache_size::Int
end

function get_children_cached(nav::AddressNavigator, addr::AngledInternalAddress)
    if haskey(nav.cache.children_cache, addr)
        return nav.cache.children_cache[addr]
    end
    
    children = generate_children(addr)
    
    # Implement LRU cache eviction if needed
    if length(nav.cache.children_cache) >= nav.cache.max_cache_size
        # Remove oldest entry
        delete!(nav.cache.children_cache, first(keys(nav.cache.children_cache)))
    end
    
    nav.cache.children_cache[addr] = children
    return children
end
```

#### User Experience Improvements
```julia
# Save/restore session state
function save_session(nav::AddressNavigator, filename::String="mandelbrot_session.json")
    session_data = Dict(
        "current_address" => serialize_address(nav.current_address),
        "history" => [serialize_address(addr) for addr in nav.history_stack],
        "bookmarks" => Dict(k => serialize_address(v) for (k,v) in nav.bookmarks)
    )
    
    open(filename, "w") do f
        JSON.print(f, session_data, 2)
    end
end

function load_session(filename::String="mandelbrot_session.json")
    if isfile(filename)
        session_data = JSON.parsefile(filename)
        # Restore navigator state
        return restore_navigator_from_data(session_data)
    end
    
    return nothing
end
```

## Integration Points

### With Existing Codebase
- **Use `newdenominator()`** from `src/angledoubling.jl:285`
- **Use `admissible()`** from `src/angledoubling.jl:141`
- **Use `treeplot()`** from `ext/GLMakieExt/showtree.jl:82`
- **Use address formatting** from existing `show()` methods

### With Future Features
- **Bonito.jl integration**: CLI could launch web interface
- **InteractiveViz.jl**: CLI could trigger dynamic visualizations
- **Export features**: CLI could save current view/session

## Testing Strategy

```julia
@testset "CLI Interface" begin
    @testset "Navigation State" begin
        nav = AddressNavigator(AngledInternalAddress([1], []), 1, 0, 24, [], Dict())
        @test nav.current_address.addr == [1]
        
        # Test children generation
        children = generate_children(nav.current_address)
        @test length(children) > 0
    end
    
    @testset "Key Handling" begin
        nav = test_navigator()
        
        # Test navigation
        @test handle_key_input(nav, 'j') == :continue
        @test nav.cursor_position > 1
        
        @test handle_key_input(nav, 'q') == :quit
    end
end
```

## Success Criteria

- [ ] Full ranger-like navigation working
- [ ] Integration with existing mathematical functions
- [ ] Search and filtering capabilities
- [ ] Visualization integration
- [ ] Session save/restore
- [ ] Performance acceptable for real-time use
- [ ] User experience smooth and intuitive
- [ ] Cross-platform compatibility

## Deployment

The CLI could be deployed as:
1. **Script mode**: `julia cli.jl` 
2. **REPL integration**: `mandelbrot_navigate()`
3. **Standalone binary**: Using PackageCompiler.jl

## Related Issues

- Complements web interface development
- May inform InteractiveViz.jl integration design
- Could replace current Phonebook interface entirely

## References

- `sandbox/apps/Phonebook.jl` (current interface to replace)
- REPL.TerminalMenus documentation
- ranger file manager (UI inspiration)
- Existing address navigation functions