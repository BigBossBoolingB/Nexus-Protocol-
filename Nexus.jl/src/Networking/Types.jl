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
