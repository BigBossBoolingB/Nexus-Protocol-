module Mempool

using ..Core # To get the Transaction type

# The Mempool is a thread-safe, in-memory store for validated transactions
# waiting to be included in a block. A Set is used to ensure uniqueness.
struct Mempool
    transactions::Set{Transaction}
    lock::ReentrantLock
end

# A global, singleton instance of the Mempool for the entire node.
const GLOBAL_MEMPOOL = Mempool(Set{Transaction}(), ReentrantLock())

"""
    add!(tx::Transaction) -> Bool

Adds a validated transaction to the global mempool in a thread-safe manner.
Returns `true` if the transaction was added, `false` if it was already present.
"""
function add!(tx::Transaction)
    lock(GLOBAL_MEMPOOL.lock)
    try
        # `push!` on a Set returns the set itself if the item was added,
        # or `nothing` if the item was already present. We check for this.
        original_size = length(GLOBAL_MEMPOOL.transactions)
        push!(GLOBAL_MEMPOOL.transactions, tx)
        new_size = length(GLOBAL_MEMPOOL.transactions)
        return new_size > original_size
    finally
        unlock(GLOBAL_MEMPOOL.lock)
    end
end

"""
    get_all() -> Vector{Transaction}

Returns a copy of all transactions currently in the mempool in a thread-safe way.
"""
function get_all()
    lock(GLOBAL_MEMPOOL.lock)
    try
        return collect(GLOBAL_MEMPOOL.transactions)
    finally
        unlock(GLOBAL_MEMPOOL.lock)
    end
end

"""
    clear!()

Removes all transactions from the mempool. Primarily for testing purposes.
"""
function clear!()
    lock(GLOBAL_MEMPOOL.lock)
    try
        empty!(GLOBAL_MEMPOOL.transactions)
    finally
        unlock(GLOBAL_MEMPOOL.lock)
    end
end

end # module Mempool
