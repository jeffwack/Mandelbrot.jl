# Simple test script to verify the new Makie extension works
# Run this after restructuring to ensure everything loads correctly

println("Testing Mandelbrot MakieExt...")

# Test loading the main package
using Mandelbrot
println("✓ Mandelbrot package loaded")

# Test loading with GLMakie backend
try
    using GLMakie
    println("✓ GLMakie backend loaded")
    
    # Test that extension loaded
    println("✓ Extension should have loaded (check for load message above)")
    
    # Debug: Check what's available in the namespace
    println("Available names containing 'plot': ", filter(x -> occursin("plot", string(x)), names(Main)))
    
    # Test basic recipe functions are available
    if isdefined(Main, :hubbardtreeplot)
        println("✓ hubbardtreeplot found")
    else
        println("❌ hubbardtreeplot not found")
    end
    
    if isdefined(Main, :mandelbrotsetplot)
        println("✓ mandelbrotsetplot found")  
    else
        println("❌ mandelbrotsetplot not found")
    end
    
    if isdefined(Main, :juliasetplot)
        println("✓ juliasetplot found")
    else
        println("❌ juliasetplot not found")
    end
    
    # Test creating a simple plot (don't display, just create)
    fig = hubbardtreeplot(1//3, style=:dendrogram)
    println("✓ hubbardtreeplot recipe works")
    
    fig = mandelbrotsetplot(0.0+0.0im, 4.0, resolution=(100, 100), max_iterations=10)
    println("✓ mandelbrotsetplot recipe works")
    
    fig = juliasetplot(-0.3+0.0im, 2.0, resolution=(50, 50), max_iterations=10)
    println("✓ juliasetplot recipe works")
    
    println("\n🎉 All tests passed! The MakieExt extension is working correctly.")
    
catch e
    println("❌ Error during testing: $e")
    rethrow(e)
end