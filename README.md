<h1 align="center">
    AirfoilDefinitions.jl
</h1>

<div align="center">

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://gabrielbdsantos.github.io/AirfoilDefinitions.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://gabrielbdsantos.github.io/AirfoilDefinitions.jl/dev/)
[![Build Status](https://github.com/gabrielbdsantos/AirfoilDefinitions.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/gabrielbdsantos/AirfoilDefinitions.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

</div>

AirfoilDefinitions.jl is a Julia package for generating two-dimensional,
chord-normalized airfoil geometries using parametric airfoil definitions.

It supports the following parameterization methods:

- [x] `AirfoilFile`
- [x] `CST`
- [ ] `HicksHenne`
- [x] `NACA4`
- [ ] `NACA5`
- [ ] `NACA6`
- [ ] `PARSEC`

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
  trailing edge (Selig ordering).

<div align="center">
<img
    src="./docs/src/assets/selig-ordering.png"
    alt="Selig ordering"
    style="width: 20vw; min-width: 250px;"
    />

<br/>
<p align="center">
    Coordinates arranged according to the Selig ordering.
    Source:
    <a href="https://doi.org/10.2514/1.J059317">https://doi.org/10.2514/1.J059317</a>.
</p>
</div>

## Contributing

Contributions are welcome, particularly new airfoil definition methods and
improvements to existing implementations. Please open an issue to discuss
substantial changes or new parameterization methods before submitting a pull
request.

## License

AirfoilDefinitions.jl is released under the terms of the MIT license. See the
[License](./LICENSE) file for further details.
