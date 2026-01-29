using AirfoilDefinitions
using Documenter

DocMeta.setdocmeta!(AirfoilDefinitions, :DocTestSetup, :(using AirfoilDefinitions); recursive=true)

makedocs(;
    modules=[AirfoilDefinitions],
    authors="Gabriel B. Santos <gabriel.bertacco@unesp.br>",
    sitename="AirfoilDefinitions.jl",
    format=Documenter.HTML(;
        canonical="https://gabrielbdsantos.github.io/AirfoilDefinitions.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/gabrielbdsantos/AirfoilDefinitions.jl",
    devbranch="main",
)
