//
//  Perspective3D.swift
//  Pokemon
//
//  Created by Bern on 2025/11/3.
//

import SwiftUI

struct Perspective3D: ViewModifier {
    @Binding var isFlipped: Bool

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0)
            )
    }
}
