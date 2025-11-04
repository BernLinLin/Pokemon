//
//  PokemonListView.swift
//  Pokemon
//
//  Created by Bern on 2025/11/2.
//

import SwiftUI

struct PokemonListView<PokemonListViewModel: PokemonListViewModelProtocol>: View {
    
    @State var viewModel: PokemonListViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.pokemon, id: \.id) { vm in
                    PokemonItemView(pokemon: vm)
                }
            }
            .listStyle(.insetGrouped)
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.primary)
                        .accessibilityLabel("Loading")
                }
            }
            .navigationTitle("Pokémon")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await viewModel.requestPokemon()
        }
    }
}

private struct PokemonItemView<ViewModel: PokemonViewModelProtocol>: View {
    @Namespace private var namespace
    
    var pokemon: ViewModel
    
    var body: some View {
        NavigationLink {
            PokemonDetailView(viewModel: PokemonDetailViewModel(pokemon: pokemon))
                .navigationTransition(
                    .zoom(sourceID: pokemon.id, in: namespace)
                )
        } label: {
            AsynImageView(viewModel: pokemon)
                .matchedTransitionSource(id: pokemon.id, in: namespace)
        }
        .accessibilityLabel(pokemon.name)
        .accessibilityHint("Double tap for details")
    }
}

#Preview {
    @Previewable
    @Environment(\.modelContext) var modelContext
    PokemonListView(
        viewModel: PokemonListViewModel(modelContext: modelContext)
    )
}

