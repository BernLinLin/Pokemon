//
//  PokemonApp.swift
//  Pokemon
//
//  Created by Bern on 2025/11/2.
//

import SwiftUI
import SwiftData

@main
struct PokemonApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Pokemon.self])
    }
}


// MARK: - Root view
private struct RootView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        PokemonListView(
            viewModel: PokemonListViewModel(modelContext: modelContext)
        )
    }
}
