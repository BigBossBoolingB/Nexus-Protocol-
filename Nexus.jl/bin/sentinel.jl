"""
The entry point for a Sentinel node. This script initializes all necessary
modules and starts the main network loop.
"""
# Add the project's src directory to the load path
push!(LOAD_PATH, joinpath(@__DIR__, "../src"))

using Nexus

function main()
    println("--- Initializing Sentinel Node ---")

    # Initialize the blockchain
    println("Initializing blockchain...")
    Nexus.Consensus.BlockBuilder.initialize_chain!()

    # Start the metrics server in the background
    println("Launching Metrics Watchtower...")
    @async Nexus.Metrics.start_metrics_server()

    # Start the main P2P listener loop
    # This is a blocking call and should be one of the last things to start.
    println("Starting P2P listener...")
    # Nexus.Networking.P2P.listen(8787) # Placeholder for main loop

    println("--- Sentinel Node is online and fortifying the network ---")

    # Keep the main task alive
    while true
        sleep(60)
        # In a real node, this loop would handle node logic,
        # like initiating block forging.
        println("Node is alive...")
    end
end

# Execute the main function
main()
