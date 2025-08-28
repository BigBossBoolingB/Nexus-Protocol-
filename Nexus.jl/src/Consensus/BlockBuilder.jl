module BlockBuilder

using ..Core
using JSON
using Nettle

"""
    compute_merkle_root(transactions::Vector{Transaction}) -> String

Computes the Merkle root for a list of transactions. The Merkle root is a
cryptographic hash that uniquely represents the entire set of transactions,
ensuring their integrity within a block.
"""
function compute_merkle_root(transactions::Vector{Transaction})
    if isempty(transactions)
        # Return a fixed, known hash for an empty set of transactions
        return bytes2hex(digest("sha256", ""))
    end

    # 1. Get the hash of each transaction's JSON representation to form the leaf nodes.
    leaf_hashes = [bytes2hex(digest("sha256", JSON.json(tx))) for tx in transactions]

    # The loop continues as long as there is more than one hash in the list
    while length(leaf_hashes) > 1
        # If there's an odd number of hashes, duplicate the last one to create a pair.
        if isodd(length(leaf_hashes))
            push!(leaf_hashes, last(leaf_hashes))
        end

        new_level_hashes = String[]
        # Process pairs of hashes to create the next level of the tree
        for i in 1:2:length(leaf_hashes)
            # Concatenate the pair of hashes
            combined_hash_data = leaf_hashes[i] * leaf_hashes[i+1]
            # Hash the combined data to create the parent node's hash
            parent_hash = bytes2hex(digest("sha256", combined_hash_data))
            push!(new_level_hashes, parent_hash)
        end
        # Move up to the next level of the tree
        leaf_hashes = new_level_hashes
    end

    # The final remaining hash is the Merkle root of the tree
    return leaf_hashes[1]
end


"""
    create_genesis_block() -> Block

Creates the very first block in the blockchain, the Genesis Block.
This block is unique as it has no parent and contains a special message.
"""
function create_genesis_block()
    # The genesis message, permanently inscribed in the first transaction.
    genesis_message = "A fortress is not built to be invincible, but to endure."

    # Create a special genesis transaction.
    # The public key and signature are placeholders, as this transaction
    # originates from the protocol itself, not a user.
    genesis_payload = TransactionPayload(genesis_message, 0.0, 1672531200.0) # Using a fixed timestamp
    genesis_transaction = Transaction(genesis_payload, UInt8[], UInt8[])

    transactions = [genesis_transaction]
    merkle_root = compute_merkle_root(transactions)

    # Construct the Genesis Block header.
    header = Dict(
        "index" => 0,
        "previous_hash" => "0"^64, # 64 zeros for a SHA-256 hash
        "timestamp" => 1672531200.0, # A fixed, arbitrary timestamp
        "merkle_root" => merkle_root
    )

    genesis_block = Block(header, transactions)
    println("BlockBuilder: Genesis Block created.")
    return genesis_block
end


# A simple, in-memory representation of the blockchain for development.
# In a real system, this would be a persistent, on-disk database.
const BLOCKCHAIN = Block[]

"""
    initialize_chain!()

Initializes the blockchain by clearing any existing state and adding the
Genesis Block. This should be called once when a node starts.
"""
function initialize_chain!()
    empty!(BLOCKCHAIN)
    genesis_block = create_genesis_block()
    push!(BLOCKCHAIN, genesis_block)
    println("BlockBuilder: Blockchain initialized with Genesis Block.")
end

"""
    get_previous_hash() -> String

Retrieves the hash of the most recent block in the chain.
NOTE: The hash of a block is defined as the hash of its header.
"""
function get_previous_hash()
    latest_block = last(BLOCKCHAIN)
    header_json = JSON.json(latest_block.header)
    return bytes2hex(digest("sha256", header_json))
end


"""
    forge_block() -> Union{Block, Nothing}

The core function of the BlockBuilder. It gathers transactions from the
Mempool, constructs a new block, and adds it to the chain.

Returns the new `Block` if successful, or `nothing` if the mempool is empty.
"""
function forge_block()
    transactions = Mempool.get_all()
    if isempty(transactions)
        println("BlockBuilder: No transactions in mempool. Nothing to forge.")
        return nothing
    end
    println("BlockBuilder: Forging new block with $(length(transactions)) transactions...")

    previous_hash = get_previous_hash()
    latest_block_index = last(BLOCKCHAIN).header["index"]

    merkle_root = compute_merkle_root(transactions)

    header = Dict(
        "index" => latest_block_index + 1,
        "previous_hash" => previous_hash,
        "timestamp" => time(),
        "merkle_root" => merkle_root
    )

    new_block = Block(header, transactions)

    push!(BLOCKCHAIN, new_block)
    println("BlockBuilder: New block forged and added to the chain.")

    Mempool.clear!()
    println("BlockBuilder: Mempool cleared.")

    # NOTE: The calling process (e.g., the main node loop) is responsible
    # for broadcasting this new block to the network via P2P.broadcast().
    return new_block
end


"""
    validate_and_append_block(block::Block) -> Bool

Validates a block received from a peer and, if valid, appends it to the
local blockchain.

Validation checks include:
- The block's index must be correct.
- The block's `previous_hash` must match the hash of the current latest block.
"""
function validate_and_append_block(block::Block)
    try
        latest_block = last(BLOCKCHAIN)

        # 1. Validate the index
        expected_index = latest_block.header["index"] + 1
        if block.header["index"] != expected_index
            println("Block Validation FAILED: Invalid index. Expected $expected_index, got $(block.header["index"]).")
            return false
        end

        # 2. Validate the previous_hash
        expected_previous_hash = get_previous_hash()
        if block.header["previous_hash"] != expected_previous_hash
            println("Block Validation FAILED: Invalid previous_hash.")
            return false
        end

        # (Future validations: check timestamp, PoA difficulty, etc.)

        # If all checks pass, append the block to the chain.
        push!(BLOCKCHAIN, block)
        println("Block Validation PASSED: New block appended to the local chain.")
        return true

    catch ex
        println("Block Validation ERROR: An unexpected error occurred: $ex")
        return false
    end
end


end # module BlockBuilder
