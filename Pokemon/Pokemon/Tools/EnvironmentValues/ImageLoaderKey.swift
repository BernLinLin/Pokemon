//
//  ImageLoaderKey.swift
//  Pokemon
//
//  Created by Bern on 2025/11/3.
//

import SwiftUI

private struct ImageLoaderKey: EnvironmentKey {
    static let defaultValue: ImageLoader = ImageLoader()
}

extension EnvironmentValues {
    var imageLoader: ImageLoader {
        get { self[ImageLoaderKey.self] }
        set { self[ImageLoaderKey.self] = newValue }
    }
}
