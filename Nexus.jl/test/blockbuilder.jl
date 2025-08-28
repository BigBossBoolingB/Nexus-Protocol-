using Test
using Nexus
using Nexus.Core.Mempool
using Nexus.Consensus.BlockBuilder
using JSON

@testset "BlockBuilder Tests" begin

    @testset "create_genesis_block Function" begin
        genesis_block = BlockBuilder.create_genesis_block()
        @test genesis_block isa Block
        @test genesis_block.header["index"] == 0
        @test genesis_block.header["previous_hash"] == "0"^64
        @test length(genesis_block.transactions) == 1

        genesis_tx_payload = genesis_block.transactions[1].payload
        @test genesis_tx_payload.destination == "A fortress is not built to be invincible, but to endure."
    end

    @testset "compute_merkle_root Function" begin
        let
            @test BlockBuilder.compute_merkle_root(Transaction[]) == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" # SHA-256 of empty string
        end
        let
            tx = Transaction(TransactionPayload("A", 1, 1.0), UInt8[], UInt8[])
            tx_hash = bytes2hex(digest("sha256", JSON.json(tx)))
            @test BlockBuilder.compute_merkle_root([tx]) == tx_hash
        end
    end

    @testset "forge_block Function" begin
        BlockBuilder.initialize_chain!()
        Mempool.clear!()

        tx1 = Transaction(TransactionPayload("Alice", 10.0, time()), rand(UInt8, 32), rand(UInt8, 64))
        tx2 = Transaction(TransactionPayload("Bob", 20.0, time()), rand(UInt8, 32), rand(UInt8, 64))
        Mempool.add!(tx1)
        Mempool.add!(tx2)

        previous_hash_before = BlockBuilder.get_previous_hash()
        @test length(BlockBuilder.BLOCKCHAIN) == 1

        new_block = BlockBuilder.forge_block()

        @test new_block isa Block
        @test length(BlockBuilder.BLOCKCHAIN) == 2
        @test new_block.header["index"] == 1
        @test new_block.header["previous_hash"] == previous_hash_before
        @test isempty(Mempool.get_all())
    end

    @testset "validate_and_append_block Function" begin
        BlockBuilder.initialize_chain!()

        let # Success case
            previous_hash = BlockBuilder.get_previous_hash()
            header = Dict("index" => 1, "previous_hash" => previous_hash, "timestamp" => time(), "merkle_root" => "abc")
            valid_block = Block(header, [])

            @test BlockBuilder.validate_and_append_block(valid_block) == true
            @test length(BlockBuilder.BLOCKCHAIN) == 2
        end

        let # Failure case: bad index
            previous_hash = BlockBuilder.get_previous_hash()
            header = Dict("index" => 3, "previous_hash" => previous_hash, "timestamp" => time(), "merkle_root" => "def")
            invalid_block = Block(header, [])

            @test BlockBuilder.validate_and_append_block(invalid_block) == false
            @test length(BlockBuilder.BLOCKCHAIN) == 2
        end

        let # Failure case: bad previous_hash
            header = Dict("index" => 3, "previous_hash" => "wrong_hash", "timestamp" => time(), "merkle_root" => "ghi")
            invalid_block = Block(header, [])

            @test BlockBuilder.validate_and_append_block(invalid_block) == false
            @test length(BlockBuilder.BLOCKCHAIN) == 2
        end
    end

end
