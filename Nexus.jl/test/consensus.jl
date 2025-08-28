using Test
using Nexus
using Nexus.Consensus
using Nexus.Consensus.PoA

@testset "Consensus Layer Tests" begin

    @testset "PoA.validate Function" begin
        # Create a sample transaction to be validated.
        # Since the actual signature verification is a placeholder,
        # the pubkey and signature can be dummy data for now.
        let
            payload = TransactionPayload("Bob", 10.0, time())
            pubkey = rand(UInt8, 32) # Dummy 32-byte public key
            signature = rand(UInt8, 64) # Dummy 64-byte signature

            tx = Transaction(payload, pubkey, signature)

            # The validate function currently returns `true` as a placeholder.
            # This test ensures that the function is callable and returns the
            # expected placeholder value, and that the hashing logic does not error.
            @test validate(tx) == true
        end

        # In the future, we would add tests for invalid signatures, malformed
        # payloads, etc., once the placeholder logic is replaced.
    end

end
