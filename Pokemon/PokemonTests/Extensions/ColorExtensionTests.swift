#if canImport(XCTest)
import XCTest
import SwiftUI
@testable import Pokemon

final class ColorExtensionTests: XCTestCase {
    func testIsLightForWhiteAndBlack() {
        XCTAssertTrue(Color.white.isLight)
        XCTAssertFalse(Color.black.isLight)
    }

    func testIsLightForMidBrightness() {
        let gray = Color(white: 0.6)
        XCTAssertFalse(gray.isLight)

        let lightGray = Color(white: 0.8)
        XCTAssertTrue(lightGray.isLight)
    }
}
#endif
