using AirfoilDefinitions
using Test
using Aqua
using JET

@testset "AirfoilDefinitions.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(AirfoilDefinitions)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(AirfoilDefinitions; target_defined_modules = true)
    end
    # Write your tests here.
end
