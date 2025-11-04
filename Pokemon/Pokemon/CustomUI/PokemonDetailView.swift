//
//  PokemonDetailView.swift
//  Pokemon
//
//  Created by Bern on 2025/11/2.
//

import SwiftUI

struct PokemonDetailView<ViewModel: PokemonDetailViewModelProtocol & Sendable>: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.imageColorAnalyzer) private var imageColorAnalyzer
    @Environment(\.imageLoader) private var imageLoader
    @Environment(\.modelContext) private var modelContext
    @Environment(\.sizeCategory) private var sizeCategory
    
    @State private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                spriteSection()
                contentSection()
            }
        }
        .task(id: viewModel.pokemon.id) {
            await viewModel.loadSpritesAndColor(
                withImageLoader: imageLoader,
                imageColorAnalyzer: imageColorAnalyzer
            )
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("\(viewModel.pokemon.name)")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
        }
        .background( background() )
    }
}

// MARK: - UI
private extension PokemonDetailView {
    
    func background() -> some View {
        VStack{
            (viewModel.color ?? .black)
            
            Color(.systemBackground)
                .frame(height: 300)
        }
        .ignoresSafeArea()
    }
    
    func spriteSection() -> some View {
        ZStack(alignment: .bottom) {
            spriteImage()
            flipButton()
        }
    }
    
    func spriteImage() -> some View {
        (viewModel.isFlipped ? viewModel.backSprite : viewModel.frontSprite)?
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 320)
            .modifier(Perspective3D(isFlipped: $viewModel.isFlipped))
            .animation(.bouncy(duration: 0.3, extraBounce: 0.1), value: viewModel.isFlipped)
            .accessibilityLabel(viewModel.pokemon.name)
    }
    
    @ViewBuilder
    func flipButton() -> some View {
        if viewModel.pokemon.backSprite != nil {
            HStack {
                Spacer()
                Image(systemName: "arrow.trianglehead.2.clockwise")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
                    .padding(6)
                    .accessibilityLabel("Flip sprite")
                    .accessibilityHint("Double tap and hold to see back sprite")
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                viewModel.flipSprite(hapticFeedback: UIImpactFeedbackGenerator(style: .light))
                            }
                            .onEnded { _ in
                                viewModel.flipSpriteBack(hapticFeedback: UIImpactFeedbackGenerator(style: .light))
                            }
                    )
            }
            .tint(viewModel.color?.isLight ?? false ? .black : .white)
            .padding()
        }
    }
    
    func contentSection() -> some View {
        VStack {
            basicInfoSection()
            sectionDivider()
            statsSection()
            sectionDivider()
            movesSection()
            bottomSpacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    func basicInfoSection() -> some View {
        VStack {
            detailRow(title: "Types", subtitle: viewModel.pokemon.types)
            detailRow(title: "Height", subtitle: viewModel.pokemon.height)
            detailRow(title: "Weight", subtitle: viewModel.pokemon.weight)
            detailRow(title: "Abilities", subtitle: viewModel.pokemon.abilities)
        }
    }
    
    func statsSection() -> some View {
        ForEach(viewModel.pokemon.stats) { stat in
            detailRowStat(
                title: stat.stat.name,
                value: stat.baseStat,
                color: viewModel.color
            )
        }
    }
    
    func movesSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Moves")
                .foregroundStyle(.secondary)
                .foregroundColor(.primary)
            Text(viewModel.pokemon.moves)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical)
        .accessibilityElement(children: .combine)
    }
    
    func detailRow(title: String, subtitle: String) -> some View {
        baseRow(title: title) {
            Text(subtitle)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
    
    func detailRowStat(title: String, value: Int, color: Color?) -> some View {
        let maxValue = max(value, 100)
        let clampedValue = max(value, 0)
        let cornerRadius: CGFloat = 8.0
        let accessibilityLabel = "\(title.capitalized): \(clampedValue) out of \(maxValue)"
        
        return baseRow(title: title.capitalized) {
            ProgressView(value: Double(clampedValue), total: Double(maxValue))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(.primary, lineWidth: 0.2)
                )
                .frame(height: 20)
                .tint(color ?? .white)
            
            
            Text("\(clampedValue) / \(maxValue)")
                .foregroundColor(.primary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }
    
    func baseRow<Content: View>(
        title: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        
        let layout = sizeCategory.isAccessibilityCategory ?
        AnyLayout(VStackLayout(alignment: .leading, spacing: 8)) :
        AnyLayout(HStackLayout(alignment: .top, spacing: 20))
        
        return layout {
            Text(title)
                .foregroundStyle(.secondary)
                .foregroundColor(.primary)
                .frame(width: sizeCategory.isAccessibilityCategory ? nil : 96, alignment: .leading)
            
            content()
        }
        .padding(.vertical)
    }
    
    func sectionDivider() -> some View {
        Divider()
            .background(.secondary)
            .padding(.vertical)
    }
    
    func bottomSpacer() -> some View {
        Spacer()
            .frame(height: 96)
    }
}


#Preview {
    let vm = PokemonDetailViewModel(pokemon: PokemonViewModel(pokemon: .pikachu))
    PokemonDetailView(viewModel: vm)
}
