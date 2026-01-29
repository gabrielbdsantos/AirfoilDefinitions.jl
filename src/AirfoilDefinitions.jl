"""
    AirfoilDefinitions

AirfoilDefinitions.jl defines 2D chord-normalized airfoil geometries using
parametric airfoil definitions.
"""
module AirfoilDefinitions

import DelimitedFiles

include("utils.jl")
include("interface.jl")
include("definitions/file.jl")
include("definitions/naca4.jl")

export UnitAirfoil, AirfoilFile, UIUC, NACA4
export coordinates

end
