# Inside make.jl
push!(LOAD_PATH,"../src/")
using Mandelbrot
using Documenter
makedocs(
         sitename = "Mandelbrot.jl",
         modules  = [Mandelbrot],
         pages=[
                "Home" => "index.md"
                "Introduction" => "introduction.md"
                "Kneading sequences" => "kneadingsequence.md"
                "Dynamic rays" => "dynamicrays.md"
                "Equipotential lines" => "equipotentials.md"
                "Finding the angle of an oriented Hubbard Tree" => "embeddedhubbardtree2angle.md"
                "Hubbard trees" => "hubbardtrees.md"
                "Images" => "images.md"
                "Julia sets" => "juliasets.md"
                "Examples of Hubbard trees" => "smallesttree.md"
               ])

deploydocs(
    repo="github.com/jeffwack/Mandelbrot.jl",
)
