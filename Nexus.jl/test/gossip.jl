using Test
using Nexus
using Nexus.Networking
using Nexus.Networking.P2P
using JSON

@testset "Gossip Protocol Tests" begin

    @testset "Message Routing for Blocks" begin
        # This test ensures that when process_message receives a NetworkMessage
        # of type "BLOCK", it correctly calls the _handle_block placeholder.
        # Since _handle_block is just a placeholder, we can't assert a specific
        # outcome, but calling it without error is a success for now.
        let
            # We don't need a real block, just a valid JSON payload string.
            block_payload_json = "{\"header\":{},\"transactions\":[]}"

            message = NetworkMessage("BLOCK", block_payload_json)
            message_json = JSON.json(message)

            # This should call process_message, which routes to _handle_block.
            # We expect it to run without error. The `@test_nowarn` macro
            # checks that the expression executes without throwing an exception.
            @test_nowarn P2P.process_message(message_json)
        end
    end

end
