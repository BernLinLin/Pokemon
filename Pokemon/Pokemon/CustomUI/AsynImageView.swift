//
//  AsynImageView.swift
//  Pokemon
//
//  Created by Bern on 2025/11/2.
//

import SwiftUI

struct AsynImageView<ViewModel: PokemonViewModelProtocol>: View {
    
    @Environment(\.imageLoader) private var imageLoader
    @Environment(\.sizeCategory) private var sizeCategory
    
    @State private var asynImage: Image?
    
    let viewModel: ViewModel
    
    @ScaledMetric var imageSize: CGFloat = 80
    
    var body: some View {
        
        let layout = sizeCategory.isAccessibilityCategory ?
        AnyLayout(VStackLayout(alignment: .leading, spacing: 16)) :
        AnyLayout(HStackLayout(alignment: .center, spacing: 16))
        
        layout {
            imageContent()
                .frame(width: imageSize, height: imageSize)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Text(viewModel.name)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
          
            Spacer()
          
        }
        .padding(.vertical, 8)
        .task(id: viewModel.id) {
            if let image = await imageLoader.loadImage(from: viewModel.frontSprite) {
                asynImage = Image(uiImage: image)
            }
        }
    }
}

// MARK: - UI
private extension AsynImageView {
    
    @ViewBuilder
    func imageContent() -> some View {
        if let asynImage = asynImage {
            asynImage
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            ProgressView()
        }
    }
}

#Preview {
    AsynImageView(viewModel: PokemonViewModel(pokemon: .pikachu))
}
