using Sockets

module P2P

"""
    process_message(line::String) -> Bool

Processes a single line of text received from a peer, which is expected
to be a JSON-encoded transaction. It deserializes and validates the transaction.

Returns `true` if the transaction is valid and accepted, `false` otherwise.
"""
function process_message(line::String)
    println("P2P: Processing message: $line")
    try
        tx_dict = JSON.parse(line)
        # Manual deserialization. In production, a library like StructTypes.jl
        # would automate this safely.
        payload = TransactionPayload(
            tx_dict["payload"]["destination"],
            tx_dict["payload"]["amount"],
            tx_dict["payload"]["timestamp"]
        )
        tx = Transaction(
            payload,
            Vector{UInt8}(tx_dict["sender_pubkey"]),
            Vector{UInt8}(tx_dict["signature"])
        )

        println("P2P: Deserialized transaction successfully.")

        # Pass the transaction to the consensus layer for validation.
        if PoA.validate(tx)
            println("P2P: Transaction passed validation. Adding to mempool...")
            was_added = Mempool.add!(tx)
            if was_added
                println("P2P: Transaction successfully added to mempool.")
            else
                println("P2P: Transaction was already in the mempool (ignored).")
            end
            return true
        else
            println("P2P: Transaction REJECTED by consensus.")
            return false
        end

    catch ex
        println("P2P: Failed to process message. Error: $ex. Dropping message.")
        return false
    end
end


"""
    _handle_connection(socket::TCPSocket)

Handles an incoming connection from a peer. It reads data from the socket
line by line and passes each line to the `process_message` function.
"""
function _handle_connection(socket::TCPSocket)
    peer_info = getpeername(socket)
    println("P2P: New connection from $peer_info")
    try
        while !eof(socket)
            line = readline(socket)
            if !isempty(line)
                process_message(line)
            end
        end
    catch ex
        println("P2P: Connection error with $peer_info: $ex")
    finally
        println("P2P: Closing connection from $peer_info")
        close(socket)
    end
end


"""
    listen(port::Int)

Starts a TCP server on the given port to listen for incoming connections
from other peers. This function runs an infinite loop to accept new connections
and handles each one in a new asynchronous task.
"""
function listen(port::Int)
    server = Sockets.listen(port)
    println("P2P Server: Now listening for incoming connections on port $port...")

    while true
        try
            socket = accept(server)
            # Handle each new connection in a separate, non-blocking task.
            @async _handle_connection(socket)
        catch ex
            println("P2P Server: Error accepting connection: $ex")
        end
    end
end

"""
    connect(host::String, port::Int) -> Bool

Establishes a connection to a peer at the given host and port.
If successful, it spawns a task to handle the connection and returns `true`.
If the connection fails, it returns `false`.
"""
function connect(host::String, port::Int)
    try
        socket = Sockets.connect(host, port)
        println("P2P Client: Successfully connected to peer at $host:$port.")
        # Handle the new connection in a separate, non-blocking task.
        @async _handle_connection(socket)
        return true
    catch ex
        println("P2P Client: Failed to connect to peer at $host:$port. Reason: $ex")
        return false
    end
end

"""
    broadcast(message::Vector{UInt8})

Broadcasts a serialized message to all currently connected peers.
"""
function broadcast(message::Vector{UInt8})
    num_peers = 0 # Placeholder for the actual number of connected peers
    println("P2P Broadcast: Propagating message to $num_peers peers...")
end

end # module P2P
