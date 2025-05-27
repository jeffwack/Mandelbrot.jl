# Inside make.jl
push!(LOAD_PATH,"../src/")
using Mandelbrot
using Documenter
makedocs(
         sitename = "Mandelbrot.jl",
         modules  = [Mandelbrot],
         pages=[
                "Home" => "index.md"
               ])

deploydocs(
    repo="github.com/jeffwack/Mandelbrot.jl",
)