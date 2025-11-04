//
//  UIImage.swift
//  Pokemon
//
//  Created by Bern on 2025/11/3.
//

import UIKit

extension UIImage {
    func resize(to targetSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: targetSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

