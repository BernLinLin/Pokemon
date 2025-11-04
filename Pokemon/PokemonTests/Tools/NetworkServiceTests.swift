#if canImport(XCTest)
import XCTest
@testable import Pokemon

final class ServiceStubURLProtocol: URLProtocol {
    static var responseData: Data?
    static var statusCode: Int = 200
    static var lastRequest: URLRequest?

    override class func canInit(with request: URLRequest) -> Bool {
        return request.url?.host == "example.com"
    }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        ServiceStubURLProtocol.lastRequest = request
        let url = request.url!
        let response = HTTPURLResponse(url: url, statusCode: ServiceStubURLProtocol.statusCode, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        if let data = ServiceStubURLProtocol.responseData {
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}

private struct FakeEndpoint: EndpointType { let path: String }
private struct FakeRequest: Requestable {
    let encoding: Request.Encoding
    let httpMethod: HTTP.Method
    let endpoint: EndpointType
    let parameters: HTTP.Parameters
}

private struct Echo: Codable { let ok: Bool }

final class NetworkServiceTests: XCTestCase {
    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(ServiceStubURLProtocol.self)
        ServiceStubURLProtocol.lastRequest = nil
        ServiceStubURLProtocol.statusCode = 200
    }
    override func tearDown() {
        URLProtocol.unregisterClass(ServiceStubURLProtocol.self)
        super.tearDown()
    }

    func testGetQueryEncodingBuildsURLWithParametersAndDecodes() async throws {
        // Prepare stub JSON
        ServiceStubURLProtocol.responseData = try! JSONEncoder().encode(Echo(ok: true))

        let service = Network.Service(server: .basic(baseURL: try! "https://example.com".asURL()))
        let req = FakeRequest(
            encoding: .query,
            httpMethod: .get,
            endpoint: FakeEndpoint(path: "resource"),
            parameters: ["q":"1","limit":"10"]
        )

        let echo: Echo = try await service.request(req)
        XCTAssertTrue(echo.ok)

        // Verify URL components
        let url = ServiceStubURLProtocol.lastRequest?.url
        XCTAssertEqual(url?.path, "/resource")
        let comps = URLComponents(url: url!, resolvingAgainstBaseURL: false)
        let items = comps?.queryItems ?? []
        let dict = Dictionary(uniqueKeysWithValues: items.map{ ($0.name, $0.value ?? "") })
        XCTAssertEqual(dict["q"], "1")
        XCTAssertEqual(dict["limit"], "10")
    }

    func testNon2xxStatusThrowsRequestFailed() async {
        ServiceStubURLProtocol.responseData = Data()
        ServiceStubURLProtocol.statusCode = 404
        let service = Network.Service(server: .basic(baseURL: try! "https://example.com".asURL()))
        let req = FakeRequest(encoding: .query, httpMethod: .get, endpoint: FakeEndpoint(path: "missing"), parameters: [:])
        do {
            let _: Echo = try await service.request(req)
            XCTFail("Expected requestFailed error")
        } catch {
            if case NetworkError.transportError(let underlying) = error,
               case NetworkError.requestFailed(let code) = underlying {
                XCTAssertEqual(code, 404)
            } else if case NetworkError.requestFailed(let code) = error {
                XCTAssertEqual(code, 404)
            } else {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
}
#endif
