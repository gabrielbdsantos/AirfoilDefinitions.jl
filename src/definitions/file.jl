"""
    AirfoilFile <: AbstractAirfoilDefinition

Airfoil definition based on coordinates stored in an external file.

The file is expected to contain two columns representing `(x, y)` coordinates.
The geometry is read and normalized when coordinates are requested.
"""
struct AirfoilFile <: AbstractAirfoilDefinition
    filename::String
end


"""
    coordinates(method::AirfoilFile; kwargs...)

Read and return normalized airfoil coordinates from a file.

The coordinates are normalized in place to a canonical reference frame (unit
chord, leading edge at the origin, Selig ordering).
"""
function coordinates(method::AirfoilFile; kwargs...)
    c = DelimitedFiles.readdlm(method.filename)
    normalize!(c)

    return c
end


"""
    UnitAirfoil(foil::AirfoilFile; kwargs...)

Construct a [`UnitAirfoil`](@ref) from the coordinates in a file.

Coordinates are read from file and normalized before being stored in the
resulting `UnitAirfoil`.
"""
function UnitAirfoil(foil::AirfoilFile; kwargs...)
    coords = coordinates(foil; kwargs...)
    return UnitAirfoil{typeof(foil), typeof(coords)}(foil, coords)
end


"""
    UIUC :: Dict{String,AirfoilFile}

Dictionary of airfoils from the UIUC Airfoil Database.

Each entry maps the airfoil name (derived from the `.dat` filename) to an
[`AirfoilFile`](@ref) constructed from the corresponding file stored in the
local `database/UIUC` directory.

The dictionary is populated automatically at load time by scanning all `.dat`
files in the UIUC database folder.
"""
const UIUC = Dict(
    begin
        db = joinpath(splitpath(@__DIR__)[1:(end - 2)]..., "database", "UIUC")
        [
            begin
                    name = split(file, ".dat")[1]
                    name => AirfoilFile(joinpath(db, file))
                end
                for file in readdir(db)
        ]
    end
)
