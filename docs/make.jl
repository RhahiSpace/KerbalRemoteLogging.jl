using KerbalRemoteLogging
using Documenter

DocMeta.setdocmeta!(KerbalRemoteLogging, :DocTestSetup, :(using KerbalRemoteLogging); recursive=true)

makedocs(;
    modules=[KerbalRemoteLogging],
    authors="Rhahi <git@rhahi.com> and contributors",
    repo="https://github.com/RhahiSpace/KerbalRemoteLogging.jl/blob/{commit}{path}#{line}",
    sitename="KerbalRemoteLogging.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://docs.rhahi.space/RemoteLogging",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/RhahiSpace/KerbalRemoteLogging.jl",
    devbranch="main",
    dirname="KerbalRemoteLogging",
)
