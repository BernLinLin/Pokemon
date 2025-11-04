#if canImport(XCTest)
import XCTest
import SwiftData
@testable import Pokemon

final class PokemonListViewModelTests: XCTestCase {

    // MARK: - Helpers
    struct FakePokemonService: PokemonServiceProtocol {
        let result: [PokemonViewModel]
        let service: APIService<PokemonService.Config> = .init(config: .init())
        func requestPokemon() async throws -> [PokemonViewModel] { result }
    }

    func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: Pokemon.self, configurations: config)
    }

    // MARK: - Tests
    @MainActor
    func testRequestPokemonPrefersStorageWhenAvailable() async throws {
        let container = try makeContainer()

        // Pre-store one Pokemon in storage
        let reader = DataStorageReader(modelContainer: container)
        try await reader.store([Pokemon.pikachu])

        let context = ModelContext(container)
        let viewModel = PokemonListViewModel(modelContext: context, pokemonService: FakePokemonService(result: []))

        await viewModel.requestPokemon()

        XCTAssertFalse(viewModel.pokemon.isEmpty)
        XCTAssertEqual(viewModel.pokemon.first?.id, Pokemon.pikachu.id)
        XCTAssertEqual(viewModel.isLoading, false)
    }

    @MainActor
    func testRequestPokemonFallsBackToAPIWhenStorageEmpty() async throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let apiVM = PokemonViewModel(pokemon: .pikachu)
        let service = FakePokemonService(result: [apiVM])
        let viewModel = PokemonListViewModel(modelContext: context, pokemonService: service)

        await viewModel.requestPokemon()

        XCTAssertEqual(viewModel.pokemon.count, 1)
        XCTAssertEqual(viewModel.pokemon.first?.id, apiVM.id)
        XCTAssertEqual(viewModel.isLoading, false)

        // Verify it was persisted
        let reader = DataStorageReader(modelContainer: container)
        let stored = try await reader.fetch(sortBy: SortDescriptor(\Pokemon.id))
        XCTAssertFalse(stored.isEmpty)
        XCTAssertEqual(stored.first?.id, apiVM.id)
    }
}
#endif