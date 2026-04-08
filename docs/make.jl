using Mandelbrot
using CairoMakie
using BrotViz
using Documenter
using DocumenterCitations
using Literate

DocMeta.setdocmeta!(Mandelbrot, :DocTestSetup, :(using Mandelbrot); recursive=true)

tests_dir = joinpath(@__DIR__, "..", "test")
generated_dir = joinpath(@__DIR__, "src", "generated")
for testfile in filter(f -> endswith(f, ".jl") && f != "runtests.jl", readdir(tests_dir))
    Literate.markdown(joinpath(tests_dir, testfile), generated_dir; flavor=Literate.DocumenterFlavor())
end
test_pages = [splitext(f)[1] => joinpath("generated", f)
                 for f in filter(f -> endswith(f, ".md"), readdir(generated_dir))]

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
                "Tree Plot Gallery" => "treeplots.md",
                "Spider Algorithm" => "spider.md",
                "Tests" => test_pages,
                "Testing Guide" => "TESTING.md",
                "Bibliography" => "bibliography.md",
    ],
)

deploydocs(;
    repo="github.com/jeffwack/Mandelbrot.jl",
    devbranch="main",
)
