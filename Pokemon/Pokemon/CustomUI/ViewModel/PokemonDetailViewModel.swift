//
//  PokemonDetailViewModel.swift
//  Pokemon
//
//  Created by Bern on 2025/11/3.
//

import Foundation

import SwiftUI // Required for Image and Color types
import SwiftData // Required for SwiftData model and context

/// Protocol defining the requirements for a Pokémon detail view model.
/// Provides state and behaviors for displaying and interacting with Pokémon details in the UI.
@MainActor
protocol PokemonDetailViewModelProtocol {
    /// The Pokémon represented by this ViewModel.
    var pokemon: PokemonViewModelProtocol { get }
    /// Indicates if the sprite is flipped (showing the back view).
    var isFlipped: Bool { get set }
    /// The image for the Pokémon's front sprite, if loaded.
    var frontSprite: Image? { get }
    /// The image for the Pokémon's back sprite, if loaded.
    var backSprite: Image? { get }
    /// The dominant color extracted from the Pokémon's sprite image, if available.
    var color: Color? { get }

    /// Loads the Pokémon's front and back sprite images and determines the dominant color.
    /// - Parameters:
    ///   - imageLoader: Helper for loading sprite images asynchronously.
    ///   - imageColorAnalyzer: Helper for extracting the dominant color from an image.
    func loadSpritesAndColor(withImageLoader imageLoader: ImageLoader, imageColorAnalyzer: ImageColorAnalyzer) async
    /// Flips the sprite to show the back, with haptic feedback.
    /// - Parameter hapticFeedback: The feedback generator for haptic response.
    func flipSprite(hapticFeedback: UIImpactFeedbackGenerator)
    /// Flips the sprite back to the front, with haptic feedback.
    /// - Parameter hapticFeedback: The feedback generator for haptic response.
    func flipSpriteBack(hapticFeedback: UIImpactFeedbackGenerator)
}

/// Observable class that manages detailed UI state and behaviors for a single Pokémon.
@Observable
final class PokemonDetailViewModel {
    // MARK: Public Properties

    /// The Pokémon to display details for.
    let pokemon: PokemonViewModelProtocol
    /// Whether the sprite is currently flipped to the back side.
    var isFlipped = false
    /// The loaded front sprite image.
    var frontSprite: Image?
    /// The loaded back sprite image (optional).
    var backSprite: Image?
    /// The dominant color extracted from the front sprite image.
    var color: Color?

    // MARK: - Initialization
    /// Creates a new ViewModel for the specified Pokémon.
    /// - Parameter pokemon: The Pokémon to represent.
    init(pokemon: PokemonViewModelProtocol) {
        self.pokemon = pokemon
    }
}

// MARK: - PokemonDetailViewModelProtocol
extension PokemonDetailViewModel: PokemonDetailViewModelProtocol {

    /// Loads the front sprite, back sprite (if available), and extracts the dominant color from the front sprite.
    /// Updates the `frontSprite`, `backSprite`, and `color` properties.
    /// - Parameters:
    ///   - spriteLoader: Loader to fetch sprite images asynchronously.
    ///   - imageColorAnalyzer: Analyzer to determine the dominant color from an image.
    func loadSpritesAndColor(withImageLoader imageLoader: ImageLoader, imageColorAnalyzer: ImageColorAnalyzer) async {
        guard let image = await imageLoader.loadImage(from: pokemon.frontSprite),
              let uicolor = await imageColorAnalyzer.dominantColor(for: pokemon.id, image: image)
        else { return }

        color = Color(uiColor: uicolor)
        frontSprite = Image(uiImage: image)

        if let backSpriteURL = pokemon.backSprite,
           let backImage = await imageLoader.loadImage(from: backSpriteURL) {
            backSprite = Image(uiImage: backImage)
        }
    }

    /// Flips the sprite to display the back image and triggers haptic feedback if not already flipped.
    /// - Parameter hapticFeedback: The haptic feedback generator.
    func flipSprite(hapticFeedback: UIImpactFeedbackGenerator) {
        guard !isFlipped else { return }
        isFlipped = true
        hapticFeedback.impactOccurred()
    }

    /// Flips the sprite back to the front image and triggers haptic feedback if not already showing the front.
    /// - Parameter hapticFeedback: The haptic feedback generator.
    func flipSpriteBack(hapticFeedback: UIImpactFeedbackGenerator) {
        guard isFlipped else { return }
        isFlipped = false
        hapticFeedback.impactOccurred()
    }
}
