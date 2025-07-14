using Mandelbrot
using Documenter

DocMeta.setdocmeta!(Mandelbrot, :DocTestSetup, :(using Mandelbrot); recursive=true)

makedocs(;
    modules=[Mandelbrot],
    authors="Jeffrey Wack <jeffwack111@gmail.com> and contributors",
    sitename="Mandelbrot.jl",
    format=Documenter.HTML(;
        canonical="https://jeffwack.github.io/Mandelbrot.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
                "Introduction" => "introduction.md",
                "Kneading sequences" => "kneadingsequence.md",
                "Dynamic rays" => "dynamicrays.md",
                "Equipotential lines" => "equipotentials.md",
                "Finding the angle of an oriented Hubbard Tree" => "embeddedhubbardtree2angle.md",
                "Hubbard trees" => "hubbardtrees.md",
                "Images" => "images.md",
                "Julia sets" => "juliasets.md",
                "Examples of Hubbard trees" => "smallesttree.md",
    ],
)

deploydocs(;
    repo="github.com/jeffwack/Mandelbrot.jl",
    devbranch="main",
)
