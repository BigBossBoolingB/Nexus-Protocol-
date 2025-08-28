using Test
using Nexus
using Sockets # Needed for the IPAddr type in the Peer struct

# Access the submodules we need to test
using Nexus.Networking
using Nexus.Networking.P2P

@testset "Networking Layer Tests" begin

    @testset "Peer Struct" begin
        @test isdefined(Nexus.Networking, :Peer)

        let
            # Use the Sockets macro to create an IP address
            ip = ip"192.168.1.1"
            p = Peer("test-peer-01", ip, 8888, 100.0)

            @test p.id == "test-peer-01"
            @test p.address == ip
            @test p.port == 8888
            @test p.trust_score == 100.0
        end
    end

    @testset "P2P Module API" begin
        @test isdefined(Nexus.Networking, :P2P)

        # Test that the placeholder functions exist and are callable
        @test isdefined(P2P, :listen)
        @test isdefined(P2P, :connect)
        @test isdefined(P2P, :broadcast)

        # Perform calls to the non-blocking functions.
        let
            # Note: P2P.listen is now a long-running server loop and cannot be
            # called directly in a unit test.

            # Test the error-handling of the connect function by trying to
            # connect to a port that is likely not in use.
            # We expect it to fail gracefully and return false.
            println("\nTesting P2P.connect failure case (this is expected to fail)...")
            @test P2P.connect("127.0.0.1", 65534) == false

            # Test the broadcast placeholder, which should just run without error.
            P2P.broadcast(UInt8[0xDE, 0xAD, 0xBE, 0xEF])
        end
    end

    @testset "P2P.process_message" begin
        # This requires JSON to be available in the test environment
        using JSON

        @test isdefined(P2P, :process_message)

        # Test the success case with a valid transaction
        let
            payload = TransactionPayload("Charlie", 50.0, time())
            tx = Transaction(payload, rand(UInt8, 32), rand(UInt8, 64))

            # Manually create the dictionary and then the JSON string
            tx_dict = Dict(
                "payload" => Dict(
                    "destination" => tx.payload.destination,
                    "amount" => tx.payload.amount,
                    "timestamp" => tx.payload.timestamp
                ),
                "sender_pubkey" => tx.sender_pubkey,
                "signature" => tx.signature
            )
            json_string = JSON.json(tx_dict)

            # Since PoA.validate is a placeholder returning true, we expect success
            @test P2P.process_message(json_string) == true
        end

        # Test the failure case with malformed JSON
        let
            malformed_json = "{\"payload\": {\"destination\": \"Dave\"}}"
            @test P2P.process_message(malformed_json) == false
        end
    end

end
