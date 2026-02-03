"""
`AirfoilDefinitions.jl` -- a Julia package for defining two-dimensional
chord-normalized airfoil geometries using parametric airfoil definitions.
"""
module AirfoilDefinitions

import DelimitedFiles
import LsqFit

include("utils.jl")
include("interface.jl")
include("definitions/file.jl")
include("definitions/naca4.jl")
include("definitions/cst.jl")

export AbstractAirfoilDefinition
export UnitAirfoil, AirfoilFile, NACA4, CST
export coordinates, normalize, normalize!

end
