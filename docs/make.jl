using Mandelbrot
using CairoMakie
using BrotViz
using Documenter
using DocumenterCitations

DocMeta.setdocmeta!(Mandelbrot, :DocTestSetup, :(using Mandelbrot); recursive=true)

bib = CitationBibliography(joinpath(@__DIR__, "src", "refs.bib"))

makedocs(;
    modules=[Mandelbrot],
    authors="Jeffrey Wack <jeffwack111@gmail.com> and contributors",
    sitename="Mandelbrot.jl",
    format=Documenter.HTML(;
        canonical="https://jeffwack.github.io/Mandelbrot.jl",
        edit_link="main",
        assets=String[],
    ),
    plugins=[bib],
    pages=[
        "Home" => "index.md",
                "Introduction" => "introduction.md",
                "Kneading sequences" => "kneadingsequence.md",
                "Dynamic rays" => "dynamicrays.md",
                "Finding the angle of an oriented Hubbard Tree" => "embeddedhubbardtree2angle.md",
                "Hubbard trees" => "hubbardtrees.md",
                "Julia sets" => "juliasets.md",
                "Examples of Hubbard trees" => "smallesttree.md",
                "Bibliography" => "bibliography.md",
    ],
)

deploydocs(;
    repo="github.com/jeffwack/Mandelbrot.jl",
    devbranch="main",
)
