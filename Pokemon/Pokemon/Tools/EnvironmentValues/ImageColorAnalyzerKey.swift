//
//  ImageColorAnalyzerKey.swift
//  Pokemon
//
//  Created by Bern on 2025/11/3.
//

import SwiftUI

private struct ImageColorAnalyzerKey: EnvironmentKey {
    static let defaultValue: ImageColorAnalyzer = ImageColorAnalyzer()
}

extension EnvironmentValues {
    var imageColorAnalyzer: ImageColorAnalyzer {
        get { self[ImageColorAnalyzerKey.self] }
        set { self[ImageColorAnalyzerKey.self] = newValue }
    }
}
