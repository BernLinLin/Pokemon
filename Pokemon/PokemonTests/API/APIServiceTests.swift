#if canImport(XCTest)
import XCTest
@testable import Pokemon

// MARK: - URLProtocol stub for APIService tests
final class APIServiceStubURLProtocol: URLProtocol {
    struct Route { let statusCode: Int; let data: Data }
    static var routes: [String: Route] = [:]
    static var capturedRequests: [URLRequest] = []

    override class func canInit(with request: URLRequest) -> Bool {
        request.url?.host == "example.com"
    }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        Self.capturedRequests.append(request)
        guard let url = request.url else { return }
        let path = url.path
        let route = Self.routes[path] ?? Route(statusCode: 200, data: Data())
        let response = HTTPURLResponse(url: url, statusCode: route.statusCode, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: route.data)
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}

// MARK: - DTO helpers to build stub JSON
private struct APIItemDTO: Codable { let name: String; let url: String }
private struct APIResponseDTO: Codable { let results: [APIItemDTO] }

private func makeListJSON(ids: [Int], base: String) -> Data {
    let items = ids.map { APIItemDTO(name: "Poke \($0)", url: "\(base)pokemon/\($0)") }
    let dto = APIResponseDTO(results: items)
    return try! JSONEncoder().encode(dto)
}

private func makeDetailJSON(id: Int) -> Data {
    let dict: [String: Any] = [
        "id": id,
        "name": "Poke \(id)",
        "weight": 10 * id,
        "height": id,
        "cries": ["latest": "sound_\(id)"],
        "sprites": [
            "front_default": "https://img.example.com/front/\(id).png",
            "back_default": "https://img.example.com/back/\(id).png"
        ],
        "abilities": [["ability": ["name": "a\(id)", "url": "https://example.com/ability"]]],
        "moves": [["move": ["name": "m\(id)", "url": "https://example.com/move"]]],
        "types": [["type": ["name": "t\(id)", "url": "https://example.com/type"]]],
        "stats": [["base_stat": 50 + id, "stat": ["name": "hp", "url": "https://example.com/stat"]]]
    ]
    let data = try! JSONSerialization.data(withJSONObject: dict, options: [])
    return data
}

final class APIServiceTests: XCTestCase {
    let baseURL = try! "https://example.com/api/".asURL()

    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(APIServiceStubURLProtocol.self)
        APIServiceStubURLProtocol.routes = [:]
        APIServiceStubURLProtocol.capturedRequests = []
    }

    override func tearDown() {
        URLProtocol.unregisterClass(APIServiceStubURLProtocol.self)
        super.tearDown()
    }

    func testRequestDataFetchesListAndDetailsAndSorts() async throws {
        // Arrange routes: list then details for ids 2 and 1
        APIServiceStubURLProtocol.routes["/api/pokemon"] = .init(statusCode: 200, data: makeListJSON(ids: [2,1], base: "https://example.com/api/"))
        APIServiceStubURLProtocol.routes["/api/pokemon/1"] = .init(statusCode: 200, data: makeDetailJSON(id: 1))
        APIServiceStubURLProtocol.routes["/api/pokemon/2"] = .init(statusCode: 200, data: makeDetailJSON(id: 2))

        let service = Network.Service(server: .basic(baseURL: baseURL))
        let api = APIService(networkService: service, config: PokemonService.Config())

        // Act
        let models = try await api.requestData()

        // Assert
        XCTAssertEqual(models.count, 2)
        XCTAssertEqual(models[0].id, 1)
        XCTAssertEqual(models[1].id, 2)
        XCTAssertEqual(models[0].name, "Poke 1")
        XCTAssertEqual(models[1].name, "Poke 2")
    }

    func testCreateRequestIncludesLimitQueryParameter() async throws {
        // Arrange: empty list response so requestData finishes quickly
        APIServiceStubURLProtocol.routes["/api/pokemon"] = .init(statusCode: 200, data: makeListJSON(ids: [], base: "https://example.com/api/"))

        let service = Network.Service(server: .basic(baseURL: baseURL))
        let api = APIService(networkService: service, config: PokemonService.Config())

        // Act
        let models = try await api.requestData()
        XCTAssertTrue(models.isEmpty)

        // Assert captured first request contains limit=1000
        let req = APIServiceStubURLProtocol.capturedRequests.first
        let comps = URLComponents(url: req!.url!, resolvingAgainstBaseURL: false)
        let dict = Dictionary(uniqueKeysWithValues: (comps?.queryItems ?? []).map { ($0.name, $0.value ?? "") })
        XCTAssertEqual(dict[ParameterKey.limit.rawValue], "1000")
    }

    func testDetailErrorPropagatesFromTransport() async {
        // List with one item -> detail 404
        APIServiceStubURLProtocol.routes["/api/pokemon"] = .init(statusCode: 200, data: makeListJSON(ids: [1], base: "https://example.com/api/"))
        APIServiceStubURLProtocol.routes["/api/pokemon/1"] = .init(statusCode: 404, data: Data())

        let service = Network.Service(server: .basic(baseURL: baseURL))
        let api = APIService(networkService: service, config: PokemonService.Config())

        do {
            _ = try await api.requestData()
            XCTFail("Expected error for detail 404")
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
