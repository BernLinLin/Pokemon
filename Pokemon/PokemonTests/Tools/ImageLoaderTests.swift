#if canImport(XCTest)
import XCTest
import UIKit
@testable import Pokemon

final class StubURLProtocol: URLProtocol {
    static var responseData: Data?
    static var statusCode: Int = 200
    static var lastRequest: URLRequest?
    static var requestCount: Int = 0

    override class func canInit(with request: URLRequest) -> Bool {
        return request.url?.host == "example.com"
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        StubURLProtocol.lastRequest = request
        StubURLProtocol.requestCount += 1
        let url = request.url!
        let response = HTTPURLResponse(url: url, statusCode: StubURLProtocol.statusCode, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        if let data = StubURLProtocol.responseData {
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

final class ImageLoaderTests: XCTestCase {
    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(StubURLProtocol.self)
        StubURLProtocol.responseData = nil
        StubURLProtocol.statusCode = 200
        StubURLProtocol.lastRequest = nil
        StubURLProtocol.requestCount = 0
    }

    override func tearDown() {
        URLProtocol.unregisterClass(StubURLProtocol.self)
        super.tearDown()
    }

    func testLoadImageCachesResponse() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        let session = URLSession(configuration: config)
        let cache = URLCache(memoryCapacity: 10_000_000, diskCapacity: 0, diskPath: nil)
        let loader = ImageLoader(session: session, cache: cache)

        let image = makeSolidImage(color: .purple, size: CGSize(width: 16, height: 16))
        StubURLProtocol.responseData = image.pngData()!

        let url = "https://example.com/image.png"
        let first = await loader.loadImage(from: url)
        XCTAssertNotNil(first)
        XCTAssertEqual(StubURLProtocol.requestCount, 1)

        let second = await loader.loadImage(from: url)
        XCTAssertNotNil(second)
        XCTAssertEqual(StubURLProtocol.requestCount, 1)
    }

    func testLoadImageInvalidURLReturnsNil() async throws {
        let loader = ImageLoader()
        let image = await loader.loadImage(from: "not_a_url")
        XCTAssertNil(image)
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
