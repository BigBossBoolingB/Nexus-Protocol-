module Metrics

using HTTP
using Sockets
using .Core
using .Consensus.BlockBuilder

# --- Metric Types (Simple, Prometheus-compatible Implementation) ---
# In a real-world scenario, a dedicated library like Prometheus.jl would be used.
# This custom implementation avoids external dependencies for this architectural step.

abstract type Metric end

mutable struct Counter <: Metric
    name::String
    help::String
    value::Float64
    lock::ReentrantLock
end

mutable struct Gauge <: Metric
    name::String
    help::String
    value::Float64
    lock::ReentrantLock
end

# --- Core Metric Definitions ---

const TRANSACTIONS_PROCESSED = Counter("nexus_transactions_processed_total", "Total number of transactions processed.", 0, ReentrantLock())
const CONNECTED_PEERS = Gauge("nexus_connected_peers", "Current number of connected peers.", 0, ReentrantLock())
const MEMPOOL_SIZE = Gauge("nexus_mempool_size", "Number of transactions in the mempool.", 0, ReentrantLock())
const BLOCK_HEIGHT = Gauge("nexus_block_height", "The current block height of the local chain.", 0, ReentrantLock())

const ALL_METRICS = [TRANSACTIONS_PROCESSED, CONNECTED_PEERS, MEMPOOL_SIZE, BLOCK_HEIGHT]

# --- Helper Functions ---

function format_metric(m::Metric)
    metric_type = m isa Counter ? "counter" : "gauge"
    return "# HELP $(m.name) $(m.help)\n# TYPE $(m.name) $(metric_type)\n$(m.name) $(m.value)\n"
end

function update_metrics!()
    # Placeholder function to update gauge values before serving.
    # In a real system, this would be called periodically or on events.
    lock(MEMPOOL_SIZE.lock)
    try
        # This requires access to Mempool and BlockBuilder state
        MEMPOOL_SIZE.value = length(Mempool.get_all())
        if !isempty(BlockBuilder.BLOCKCHAIN)
            BLOCK_HEIGHT.value = BlockBuilder.BLOCKCHAIN[end].header["index"]
        end
    finally
        unlock(MEMPOOL_SIZE.lock)
    end
end

# --- Metrics Server ---

"""
    start_metrics_server(host="0.0.0.0", port=9090)

Starts an HTTP server to expose the collected metrics in Prometheus format.
This function should be run as an asynchronous task.
"""
function start_metrics_server(host="0.0.0.0", port=9090)
    println("Metrics Watchtower: Exposing /metrics on $host:$port...")
    HTTP.serve(host, port) do request::HTTP.Request
        if request.target == "/metrics"
            update_metrics!() # Update gauges on-demand

            body = IOBuffer()
            for m in ALL_METRICS
                lock(m.lock)
                try
                    write(body, format_metric(m))
                finally
                    unlock(m.lock)
                end
            end
            return HTTP.Response(200, ["Content-Type" => "text/plain; version=0.0.4"], String(take!(body)))
        else
            return HTTP.Response(404, "Not Found")
        end
    end
end

end # module Metrics
