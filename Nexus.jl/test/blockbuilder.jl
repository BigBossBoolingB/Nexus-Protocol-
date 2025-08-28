using Test
using Nexus
using Nexus.Core.Mempool
using Nexus.Consensus.BlockBuilder
using JSON

@testset "BlockBuilder Tests" begin

    # Reset the blockchain and mempool before these tests to ensure independence
    Mempool.clear!()
    # Note: We can't easily reset the BLOCKCHAIN const, so tests are order-dependent.
    # A more advanced setup would pass the chain as an argument.
    # For now, we design tests to run in sequence.

    @testset "compute_merkle_root Function" begin
        let
            # Test with an empty list of transactions
            @test BlockBuilder.compute_merkle_root(Transaction[]) == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" # SHA-256 of empty string
        end
        let
            # Test with a single transaction
            tx = Transaction(TransactionPayload("A", 1, 1.0), UInt8[], UInt8[])
            tx_hash = bytes2hex(digest("sha256", JSON.json(tx)))
            @test BlockBuilder.compute_merkle_root([tx]) == tx_hash
        end
    end

    @testset "forge_block Function" begin
        # 1. Test forging a block with transactions
        let
            Mempool.clear!()
            # Seed the mempool
            tx1 = Transaction(TransactionPayload("Alice", 10.0, time()), rand(UInt8, 32), rand(UInt8, 64))
            tx2 = Transaction(TransactionPayload("Bob", 20.0, time()), rand(UInt8, 32), rand(UInt8, 64))
            Mempool.add!(tx1)
            Mempool.add!(tx2)

            # Get the state before forging
            previous_hash_before = BlockBuilder.get_previous_hash()
            previous_index_before = BlockBuilder.BLOCKCHAIN[end].header["index"]

            # Forge the new block
            new_block = BlockBuilder.forge_block()

            @test new_block isa Block
            @test length(new_block.transactions) == 2
            @test new_block.header["index"] == previous_index_before + 1
            @test new_block.header["previous_hash"] == previous_hash_before
            @test !isempty(new_block.header["merkle_root"])
            @test new_block.header["merkle_root"] == BlockBuilder.compute_merkle_root([tx1, tx2])

            # Verify the mempool was cleared
            @test isempty(Mempool.get_all())
        end

        # 2. Test forging with an empty mempool
        let
            Mempool.clear!()
            @test BlockBuilder.forge_block() === nothing
        end
    end

end
