<h1 align="center">
    AirfoilDefinitions.jl
</h1>

<div align="center">

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://gabrielbdsantos.github.io/AirfoilDefinitions.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://gabrielbdsantos.github.io/AirfoilDefinitions.jl/dev/)
[![Build Status](https://github.com/gabrielbdsantos/AirfoilDefinitions.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/gabrielbdsantos/AirfoilDefinitions.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

</div>

AirfoilDefinitions.jl is a Julia package for generating 2D chord-normalized
airfoil geometries using parametric airfoil definitions. It focuses on airfoil
definitions rather than airfoil manipulation and geometry discretization.

It currently supports the following parameterization methods:

- `AirfoilFile`: read airfoil coordinates from file.
- `UIUC`: dictionary of more than 1600 airfoils from the UIUC database.
- `NACA4`: four-digit NACA series, covering both open and closed trailing edge
  formulations.

## License

AirfoilDefinitions.jl is released under the terms of the MIT license. See
[License](./LICENSE) for further details.
