using Test

# Add the project's src directory to the load path to find the Nexus module.
# This only needs to be done once in the main runner.
push!(LOAD_PATH, joinpath(@__DIR__, "../src"))

@testset "Nexus.jl: The Complete Test Suite" begin
    println("Running Core tests...")
    @testset "Core" begin
        include("core.jl")
        include("mempool.jl")
    end

    println("\nRunning Networking tests...")
    @testset "Networking" begin include("networking.jl") end

    println("\nRunning Consensus tests...")
    @testset "Consensus" begin include("consensus.jl") end
end
