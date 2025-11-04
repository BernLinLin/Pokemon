#if canImport(XCTest)
import XCTest
import UIKit
@testable import Pokemon

final class ImageColorAnalyzerTests: XCTestCase {
    func testDominantColorFromSolidImage() async throws {
        let analyzer = ImageColorAnalyzer()
        let redImage = makeSolidImage(color: .red, size: CGSize(width: 60, height: 60))
        let color = await analyzer.dominantColor(for: 1, image: redImage)
        XCTAssertNotNil(color)
        // Expect the resulting color to be close to red
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color!.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertGreaterThan(r, 0.9)
        XCTAssertLessThan(g, 0.2)
        XCTAssertLessThan(b, 0.2)
    }

    func testDominantColorCachesById() async throws {
        let analyzer = ImageColorAnalyzer()
        let red = makeSolidImage(color: .red, size: CGSize(width: 40, height: 40))
        _ = await analyzer.dominantColor(for: 99, image: red)

        // Different image but same id should return cached color
        let green = makeSolidImage(color: .green, size: CGSize(width: 40, height: 40))
        let cached = await analyzer.dominantColor(for: 99, image: green)
        XCTAssertNotNil(cached)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        cached!.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertGreaterThan(r, 0.7)
        XCTAssertLessThan(g, 0.3)
    }

    // MARK: - Helpers
    private func makeSolidImage(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        color.setFill()
        UIBezierPath(rect: CGRect(origin: .zero, size: size)).fill()
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}
#endif