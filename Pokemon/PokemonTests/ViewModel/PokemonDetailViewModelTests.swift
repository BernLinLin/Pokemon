#if canImport(XCTest)
import XCTest
import SwiftUI
import UIKit
@testable import Pokemon

final class DetailStubURLProtocol: URLProtocol {
    static var responses: [String: Data] = [:]
    override class func canInit(with request: URLRequest) -> Bool { request.url?.host == "example.com" }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        let url = request.url!
        let data = DetailStubURLProtocol.responses[url.absoluteString] ?? Data()
        let resp = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: resp, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}

private struct FakeVM: PokemonViewModelProtocol {
    var frontSprite: String
    var backSprite: String?
    var types: String = "electric"
    var abilities: String = "static"
    var name: String = "Pika"
    var stats: [Stat] = []
    var moves: String = ""
    var height: String = "0.4 m"
    var weight: String = "6.0 kg"
    var id: Int
    var latestCry: String? = nil
}

final class PokemonDetailViewModelTests: XCTestCase {
    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(DetailStubURLProtocol.self)
    }
    override func tearDown() {
        URLProtocol.unregisterClass(DetailStubURLProtocol.self)
        super.tearDown()
    }

    @MainActor
    func testLoadSpritesAndColorSetsImagesAndColor() async throws {
        // Prepare stub images
        let front = makeSolidImage(color: .red, size: CGSize(width: 24, height: 24)).pngData()!
        let back = makeSolidImage(color: .blue, size: CGSize(width: 24, height: 24)).pngData()!
        DetailStubURLProtocol.responses["https://example.com/front.png"] = front
        DetailStubURLProtocol.responses["https://example.com/back.png"] = back

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [DetailStubURLProtocol.self]
        let loader = ImageLoader(session: URLSession(configuration: config))

        let vmData = FakeVM(frontSprite: "https://example.com/front.png", backSprite: "https://example.com/back.png", id: 25)
        let vm = PokemonDetailViewModel(pokemon: vmData)
        let analyzer = ImageColorAnalyzer()

        await vm.loadSpritesAndColor(withImageLoader: loader, imageColorAnalyzer: analyzer)
        XCTAssertNotNil(vm.frontSprite)
        XCTAssertNotNil(vm.backSprite)
        XCTAssertNotNil(vm.color)
    }

    @MainActor
    func testFlipBehaviorTogglesState() {
        let vmData = FakeVM(frontSprite: "https://example.com/front.png", backSprite: "https://example.com/back.png", id: 26)
        let vm = PokemonDetailViewModel(pokemon: vmData)
        let haptic = UIImpactFeedbackGenerator(style: .light)

        XCTAssertFalse(vm.isFlipped)
        vm.flipSprite(hapticFeedback: haptic)
        XCTAssertTrue(vm.isFlipped)
        vm.flipSpriteBack(hapticFeedback: haptic)
        XCTAssertFalse(vm.isFlipped)
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