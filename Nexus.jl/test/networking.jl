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

        # Perform simple calls to the placeholder functions.
        # This primarily validates their signatures. We expect them to run without error.
        let
            # P2P.listen should just print a message and do nothing else
            # We can't easily capture stdout here, so we just call it to ensure no crash.
            P2P.listen(9000)

            # P2P.connect should return true as a placeholder
            @test P2P.connect("localhost", 9001) == true

            # P2P.broadcast should just print a message
            P2P.broadcast(UInt8[0xDE, 0xAD, 0xBE, 0xEF])
        end
    end

end
