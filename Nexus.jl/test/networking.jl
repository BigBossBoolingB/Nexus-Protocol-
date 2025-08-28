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

        # Perform simple calls to the non-blocking placeholder functions.
        # This primarily validates their signatures.
        let
            # Note: P2P.listen is now a long-running server loop and cannot be
            # called directly in a unit test without causing it to hang.
            # Its functionality will be validated through integration tests.

            # Test the remaining non-blocking functions
            @test P2P.connect("localhost", 9001) == true
            P2P.broadcast(UInt8[0xDE, 0xAD, 0xBE, 0xEF])
        end
    end

end
