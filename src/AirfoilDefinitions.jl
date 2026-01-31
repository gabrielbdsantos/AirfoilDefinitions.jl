"""
    AirfoilDefinitions

AirfoilDefinitions.jl defines 2D chord-normalized airfoil geometries using
parametric airfoil definitions.
"""
module AirfoilDefinitions

export AbstractAirfoilDefinition
export UnitAirfoil, AirfoilFile, NACA4
# export UIUC
export coordinates

import DelimitedFiles

include("utils.jl")
include("interface.jl")
include("definitions/file.jl")
# include("definitions/database.jl")
include("definitions/naca4.jl")

end
