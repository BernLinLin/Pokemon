#if canImport(XCTest)
import XCTest
import UIKit
@testable import Pokemon

final class UIImageExtensionTests: XCTestCase {
    func testResizeProducesExpectedSize() {
        let original = makeSolidImage(color: .blue, size: CGSize(width: 100, height: 50))
        let resized = original.resize(to: CGSize(width: 40, height: 20))
        XCTAssertNotNil(resized)
        XCTAssertEqual(resized!.size.width, 40, accuracy: 0.5)
        XCTAssertEqual(resized!.size.height, 20, accuracy: 0.5)
    }

    private func makeSolidImage(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        color.setFill()
        UIBezierPath(rect: CGRect(origin: .zero, size: size)).fill()
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}
#endif