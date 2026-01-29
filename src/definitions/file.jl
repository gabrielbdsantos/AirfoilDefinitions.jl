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
