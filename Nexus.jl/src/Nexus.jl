module Nexus

# --- Core Module ---
# Defines the fundamental data structures and constants for the entire protocol.
module Core
    include("Core/Types.jl")
    include("Core/Constants.jl")
    include("Core/Mempool.jl")
    export Mempool
end

# Expose core types at the top level for convenience
using .Core
export Transaction, Block, TransactionPayload, Mempool


# --- Consensus Module ---
# Handles all validation and consensus logic (e.g., Proof of Architecture).
module Consensus
    # Import dependencies needed for validation logic
    using ..Core
    using JSON
    using Nettle

    include("Consensus/PoA.jl")
    include("Consensus/BlockBuilder.jl")
    export PoA, BlockBuilder
end

# Make the entire Consensus module available to users of Nexus
export Consensus


# --- Networking Module ---
# Handles all peer-to-peer communication.
module Networking
    # Import dependencies needed for networking logic
    using Sockets
    using JSON
    using ..Core
    using ..Consensus
    using ..Consensus.PoA # To call the validate function

    include("Networking/Types.jl")
    include("Networking/P2P.jl")

    # Export types and submodules from the Networking submodule
    export Peer, P2P
end

# Make the entire Networking module available to users of Nexus
export Networking


# --- Metrics Module ---
# Handles instrumentation and exposure of metrics for monitoring.
module Metrics
    using HTTP
    using Sockets
    using ..Core # For Mempool
    using ..Consensus.BlockBuilder # For BLOCKCHAIN
    include("Metrics.jl")
    export start_metrics_server
end

# Make the Metrics module available to users of Nexus
export Metrics


end # module Nexus
