"""
Defines the fundamental data structures. We use structs for type stability
and performance, a key strength of Julia.
"""
struct Transaction
    source::String
    destination::String
    amount::Float64
    signature::Vector{UInt8}
end

struct Block
    header::Dict{String, Any}
    transactions::Vector{Transaction}
end
