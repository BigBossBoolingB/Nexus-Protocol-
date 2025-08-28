using Sockets

"""
Represents a peer node in the Nexus network. This structure holds all
necessary information for discovery, connection, and trust evaluation.
"""
struct Peer
    id::String          # A unique, verifiable identifier for the peer.
    address::IPAddr     # The IP address for communication.
    port::Int           # The port the peer is listening on.
    trust_score::Float64 # The score calculated by Proof of Architecture.
    # We can add more fields later, like last_seen, version, etc.
end


"""
A standardized wrapper for all messages sent over the network.
This allows recipients to easily identify and handle different types of data.
"""
struct NetworkMessage
    type::String      # The type of the message (e.g., "TRANSACTION", "BLOCK")
    payload::String   # The JSON-serialized content of the message
end
