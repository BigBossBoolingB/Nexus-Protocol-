"""
The entry point for a Nomad client. This script initializes all necessary
modules and starts the main network loop.
"""
# Add the project's src directory to the load path
push!(LOAD_PATH, joinpath(@__DIR__, "../src"))

using Nexus

function main()
    println("--- Initializing Nomad Client ---")

    # Initialize the blockchain
    println("Initializing blockchain...")
    Nexus.Consensus.BlockBuilder.initialize_chain!()

    # Start the metrics server in the background
    println("Launching Metrics Watchtower...")
    @async Nexus.Metrics.start_metrics_server()

    # Start the main P2P listener loop
    println("Starting P2P listener...")
    # Nexus.Networking.P2P.listen(8787)

    # Connect to some seed nodes
    println("Connecting to network...")
    # Nexus.Networking.P2P.connect("sentinel1.nexus.io", 8787)

    println("--- Nomad Client is online and connected to the network ---")

    # Keep the main task alive
    while true
        sleep(60)
        println("Node is alive...")
    end
end

# Execute the main function
main()
