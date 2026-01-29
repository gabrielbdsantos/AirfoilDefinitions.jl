"""
    AbstractAirfoilDefinition

Abstract supertype for airfoil generation methods.
"""
abstract type AbstractAirfoilDefinition end


"""
    UnitAirfoil{M <: AbstractAirfoilDefinition, C <: AbstractMatrix}

Canonical representation of a unit-chord airfoil.

`UnitAirfoil` stores airfoil geometry in a normalized reference frame (unit chord,
fixed orientation, Selig ordering), together with the method that produced it.

# Fields

- `method::M`: Airfoil definition method.
- `coordinates::C`: Airfoil coordinates in canonical form.
"""
struct UnitAirfoil{M <: AbstractAirfoilDefinition, C}
    method::M
    coordinates::C
end


"""
    coordinates(method::AbstractAirfoilDefinition; kwargs...)

Return the airfoil coordinates defined by `method`.

Concrete subtypes of [`AbstractAirfoilDefinition`](@ref) are expected to implement
this interface. Keyword arguments may be used to control some options of the
method.
"""
function coordinates(method::AbstractAirfoilDefinition; kwargs...) end


"""
    coordinates(foil::UnitAirfoil; kwargs...)

Return the coordinate representation of a `UnitAirfoil`.

Keyword arguments are accepted for interface consistency but are not used by
this method.
"""
coordinates(foil::UnitAirfoil; kwargs...) = foil.coordinates
