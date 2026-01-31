# """
#     UIUC :: Dict{String,AirfoilFile}
#
# Dictionary of airfoils from the
# [UIUC Airfoil Database](https://m-selig.ae.illinois.edu/ads/coord_database.html).
#
# Each entry maps the airfoil name (derived from the `.dat` filename) to an
# [`AirfoilFile`](@ref) constructed from the corresponding file stored in the
# local `database/UIUC` directory.
#
# The dictionary is populated automatically at load time by scanning all `.dat`
# files in the UIUC database folder.
# """
# const UIUC = Dict(
#     begin
#         db = joinpath(splitpath(@__DIR__)[1:(end - 2)]..., "database", "UIUC")
#         [
#             begin
#                     name = split(file, ".dat")[1]
#                     name => AirfoilFile(joinpath(db, file))
#                 end
#                 for file in readdir(db)
#         ]
#     end
# )
