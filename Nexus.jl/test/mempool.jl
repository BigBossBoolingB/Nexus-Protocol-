using Test
using Nexus
using Nexus.Core.Mempool

@testset "Mempool Tests" begin

    # Ensure the mempool is in a known state before each test run within this set.
    Mempool.clear!()

    @testset "Adding and Uniqueness" begin
        payload1 = TransactionPayload("Alice", 10.0, time())
        tx1 = Transaction(payload1, rand(UInt8, 32), rand(UInt8, 64))

        # Test adding a single, unique transaction
        @test Mempool.add!(tx1) == true
        @test length(Mempool.get_all()) == 1

        # Test adding the exact same transaction again
        @test Mempool.add!(tx1) == false
        @test length(Mempool.get_all()) == 1
    end

    @testset "Retrieval and Clearing" begin
        Mempool.clear!() # Ensure a clean state for this test set
        payload2 = TransactionPayload("Bob", 20.0, time() + 1)
        tx2 = Transaction(payload2, rand(UInt8, 32), rand(UInt8, 64))

        Mempool.add!(tx2)
        @test length(Mempool.get_all()) == 1 # Should be 1 because we just cleared.

        all_txs = Mempool.get_all()
        @test tx2 in all_txs

        Mempool.clear!()
        @test isempty(Mempool.get_all())
    end

    # Final cleanup to ensure no state leaks to other test files
    Mempool.clear!()
end
