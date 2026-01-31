# AirfoilDefinitions.jl

AirfoilDefinitions.jl is a Julia package for generating two-dimensional,
chord-normalized airfoil geometries using parametric airfoil definitions.

It supports the following parameterization methods:

- [`AirfoilFile`](@ref)
- [`NACA4`](@ref)

The following methods are planned:

- `BezierCurves`
- `CST`
- `HicksHenne`
- `NACA5`
- `NACA6`
- `PARSEC`

## Install

AirfoilDefinitions.jl is not yet a registered Julia package. So to install it,

1. Download [Julia](https://julialang.org/downloads/) version 1.10 or later.
1. Launch Julia and type

```julia-repl
julia> import Pkg
julia> Pkg.add("https://github.com/gabrielbdsantos/AirfoilDefinitions.jl")
```

## Quick start

```julia
using AirfoilDefinitions

# Step 1. Select an airfoil generation method.
airfoil = NACA4("0012"; open_trailing_edge = true)

# Step 2. Generate the coordinates
coords = coordinates(airfoil)
```

## Coordinate convention

All airfoils are defined in a two-dimensional Cartesian coordinate system with
the following conventions:

- Chord length is normalized to unity.
- The leading edge is located at `x = 0`, and the trailing edge at `x = 1`.
- Airfoil surface coordinates are ordered clockwise, starting from the upper
  trailing edge.
