using Test
using Nexus
using Nexus.Networking
using Nexus.Networking.P2P
using JSON

@testset "Gossip Protocol Tests" begin

    @testset "End-to-End Block Reception" begin
        # This test validates the full cycle:
        # NetworkMessage -> process_message -> _handle_block -> validate_and_append_block

        # 1. Reset the chain to a known state (genesis block only)
        while length(BlockBuilder.BLOCKCHAIN) > 1 pop!(BlockBuilder.BLOCKCHAIN) end
        @test length(BlockBuilder.BLOCKCHAIN) == 1

        # 2. Manually create a valid new block to be "received"
        previous_hash = BlockBuilder.get_previous_hash()
        header = Dict("index" => 1, "previous_hash" => previous_hash, "timestamp" => time(), "merkle_root" => "abc")
        valid_block = Block(header, [])

        # 3. Serialize the block and wrap it in a NetworkMessage
        block_payload_json = JSON.json(valid_block)
        message = NetworkMessage("BLOCK", block_payload_json)
        message_json = JSON.json(message)

        # 4. Process the message
        P2P.process_message(message_json)

        # 5. Verify that the block was successfully validated and appended
        @test length(BlockBuilder.BLOCKCHAIN) == 2
        @test BlockBuilder.BLOCKCHAIN[2].header["index"] == 1
        @test BlockBuilder.BLOCKCHAIN[2].header["merkle_root"] == "abc"
    end

end
