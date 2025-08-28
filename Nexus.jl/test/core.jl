using Test
using Nexus

@testset "Core Module Tests" begin
    # Test if the core types are defined and accessible
    @test isdefined(Nexus, :Transaction)
    @test isdefined(Nexus, :Block)

    # Test instantiation of the Transaction struct
    let
        tx = Transaction("Alice", "Bob", 10.5, UInt8[])
        @test tx.source == "Alice"
        @test tx.destination == "Bob"
        @test tx.amount == 10.5
        @test tx.signature == UInt8[]
    end

    # Test instantiation of the Block struct
    let
        tx = Transaction("Alice", "Bob", 10.5, UInt8[])
        b = Block(Dict("index" => 1, "timestamp" => 1672531200), [tx])
        @test b.header["index"] == 1
        @test !isempty(b.transactions)
        @test b.transactions[1].source == "Alice"
    end
end
