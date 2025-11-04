//
//  Color.swift
//  Pokemon
//
//  Created by Bern on 2025/11/3.
//

import SwiftUI

extension Color {
    var isLight: Bool {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        if UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            let brightness = (red * 299 + green * 587 + blue * 114) / 1000
            return brightness > 0.7
        }
        return false
    }
}
