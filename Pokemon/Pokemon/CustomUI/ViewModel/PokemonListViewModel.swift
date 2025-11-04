//
//  PokemonListViewModel.swift
//  Pokemon
//
//  Created by Bern on 2025/11/3.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
protocol PokemonListViewModelProtocol {
    var pokemon: [PokemonViewModel] { get }
    var isLoading: Bool { get }
    func requestPokemon() async
}

@Observable
final class PokemonListViewModel {
    
    private let pokemonService: PokemonServiceProtocol
    private let storageReader: DataStorageReader
    
    var pokemon: [PokemonViewModel] = []
    
    var isLoading: Bool = false
    
    init(modelContext: ModelContext, pokemonService: PokemonServiceProtocol = PokemonService()) {
        self.storageReader = DataStorageReader(modelContainer: modelContext.container)
        self.pokemonService = pokemonService
    }
}

// MARK: - PokemonListViewModelProtocol
extension PokemonListViewModel: PokemonListViewModelProtocol {
   
    /// Requests  `PokemonService`.
    /// If a request is already in progress, this call is ignored.
    /// On success, the results are appended to the existing Pokémon list.
    func requestPokemon() async {
        guard !isLoading else { return }

        pokemon = await withLoadingState {
            await fetchDataFromStorageOrAPI()
        }
    }
}

// MARK: - DataFetcher implementation
extension PokemonListViewModel: DataLoader {
    typealias StoredData = Pokemon
    typealias APIData = PokemonViewModel
    typealias ViewModel = PokemonViewModel

    func fetchStoredData() async throws -> [StoredData] {
        try await storageReader.fetch(sortBy: SortDescriptor(\.id))
    }

    func fetchAPIData() async throws -> [APIData] {
        try await pokemonService.requestPokemon()
    }

    func storeData(_ data: [StoredData]) async throws {
        try await storageReader.store(data)
    }

    func transformToViewModel(_ data: StoredData) -> ViewModel {
        ViewModel(pokemon: data)
    }

    func transformForStorage(_ data: ViewModel) -> StoredData {
        data.pokemon
    }
}

// MARK: - Private loading function
private extension PokemonListViewModel {
    func withLoadingState<T>(_ operation: () async throws -> T) async rethrows -> T {
        isLoading = true
        defer { isLoading = false }
        return try await operation()
    }
}
