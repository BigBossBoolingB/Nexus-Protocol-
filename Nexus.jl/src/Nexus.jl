module Nexus

# --- Core Module ---
# Defines the fundamental data structures and constants for the entire protocol.
module Core
    include("Core/Types.jl")
    include("Core/Constants.jl")
end

# Expose core types at the top level for convenience
using .Core
export Transaction, Block


# --- Networking Module ---
# Handles all peer-to-peer communication.
module Networking
    # Import Sockets for networking types and core types for context
    using Sockets
    using ..Core

    # Networking-specific types and P2P logic
    include("Networking/Types.jl")
    include("Networking/P2P.jl")

    # Export types and submodules from the Networking submodule
    export Peer, P2P
end

# Make the entire Networking module available to users of Nexus
export Networking


end # module Nexus
