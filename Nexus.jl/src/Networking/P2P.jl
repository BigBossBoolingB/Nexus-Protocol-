using Sockets

module P2P

# --- Private Message Handlers ---

function _handle_transaction(payload::String)
    println("P2P: Handling incoming transaction...")
    try
        tx_dict = JSON.parse(payload)
        payload_obj = TransactionPayload(
            tx_dict["payload"]["destination"],
            tx_dict["payload"]["amount"],
            tx_dict["payload"]["timestamp"]
        )
        tx = Transaction(payload_obj, Vector{UInt8}(tx_dict["sender_pubkey"]), Vector{UInt8}(tx_dict["signature"]))

        if PoA.validate(tx)
            println("P2P: Transaction passed validation. Adding to mempool...")
            was_added = Mempool.add!(tx)
            was_added ? println("P2P: Transaction successfully added to mempool.") : println("P2P: Transaction was already in the mempool (ignored).")
        else
            println("P2P: Transaction REJECTED by consensus.")
        end
    catch ex
        println("P2P: Failed to process transaction payload. Error: $ex")
    end
end

function _handle_block(payload::String)
    println("P2P: Handling incoming block...")
    # Placeholder for block handling logic
    # 1. Deserialize the block payload
    # 2. Call the new `validate_and_append_block` consensus function
end


# --- Main Synapse Router ---

"""
    process_message(line::String)

Processes a single line of text received from a peer. It deserializes the
line into a `NetworkMessage`, inspects its type, and delegates it to the
appropriate handler function.
"""
function process_message(line::String)
    println("P2P: Routing message: $line")
    try
        msg = JSON.parse(line)
        message = NetworkMessage(msg["type"], msg["payload"])

        if message.type == "TRANSACTION"
            _handle_transaction(message.payload)
        elseif message.type == "BLOCK"
            _handle_block(message.payload)
        else
            println("P2P: Received unknown message type: $(message.type)")
        end
    catch ex
        println("P2P: Failed to parse NetworkMessage. Error: $ex. Dropping message.")
    end
end


# --- Connection Management ---

"""
    _handle_connection(socket::TCPSocket)
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


# --- Public API ---

"""
    listen(port::Int)
"""
function listen(port::Int)
    server = Sockets.listen(port)
    println("P2P Server: Now listening for incoming connections on port $port...")
    while true
        try
            @async _handle_connection(accept(server))
        catch ex
            println("P2P Server: Error accepting connection: $ex")
        end
    end
end

"""
    connect(host::String, port::Int) -> Bool
"""
function connect(host::String, port::Int)
    try
        socket = Sockets.connect(host, port)
        println("P2P Client: Successfully connected to peer at $host:$port.")
        @async _handle_connection(socket)
        return true
    catch ex
        println("P2P Client: Failed to connect to peer at $host:$port. Reason: $ex")
        return false
    end
end

"""
    broadcast(message::NetworkMessage)

Broadcasts a message to all connected peers. This function serializes the
`NetworkMessage` and (conceptually) writes it to every active peer socket.
"""
function broadcast(message::NetworkMessage)
    # NOTE: A real implementation requires a shared, thread-safe list of active
    # peer sockets. This is a placeholder for that logic.
    # e.g., for peer_socket in get_active_sockets() ...

    num_peers = 0 # Placeholder for length(get_active_sockets())
    println("P2P Broadcast: Broadcasting message of type '$(message.type)' to $num_peers peers...")

    # 1. Serialize the message to JSON format.
    json_message = JSON.json(message)

    # 2. Loop through all active connections and send the message.
    #    This part is conceptual until a peer list is implemented.
    #
    # for socket in get_active_sockets()
    #     try
    #         write(socket, json_message * "\n")
    #     catch ex
    #         println("P2P Broadcast: Error sending to peer. Removing. Error: $ex")
    #         # Here, we would handle the dead socket, e.g., remove it from the list.
    #     end
    # end
end

end # module P2P
