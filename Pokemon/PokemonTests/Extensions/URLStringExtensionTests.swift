#if canImport(XCTest)
import XCTest
@testable import Pokemon

final class URLStringExtensionTests: XCTestCase {
    func testAsURLSuccess() throws {
        let url = try "https://example.com/path".asURL()
        XCTAssertEqual(url.host, "example.com")
        XCTAssertEqual(url.path, "/path")
    }

    func testAsURLFailure() {
        XCTAssertThrowsError(try "not_a_url".asURL()) { error in
            guard case NetworkError.invalidURL = error else {
                XCTFail("Expected invalidURL, got \(error)")
                return
            }
        }
    }
}
#endif