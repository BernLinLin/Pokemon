#if canImport(XCTest)
import XCTest
@testable import Pokemon

final class PokemonServiceStubURLProtocol: URLProtocol {
    struct Route { let statusCode: Int; let data: Data }
    static var routes: [String: Route] = [:]

    override class func canInit(with request: URLRequest) -> Bool {
        request.url?.host == "example.com"
    }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        guard let url = request.url else { return }
        let route = Self.routes[url.path] ?? Route(statusCode: 200, data: Data())
        let response = HTTPURLResponse(url: url, statusCode: route.statusCode, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: route.data)
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}

private struct APIItemDTO: Codable { let name: String; let url: String }
private struct APIResponseDTO: Codable { let results: [APIItemDTO] }

private func makeListJSON(ids: [Int], base: String) -> Data {
    let items = ids.map { APIItemDTO(name: "Poke \($0)", url: "\(base)pokemon/\($0)") }
    return try! JSONEncoder().encode(APIResponseDTO(results: items))
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
    return try! JSONSerialization.data(withJSONObject: dict, options: [])
}

final class PokemonServiceTests: XCTestCase {
    let baseURL = try! "https://example.com/api/".asURL()

    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(PokemonServiceStubURLProtocol.self)
        PokemonServiceStubURLProtocol.routes = [:]
    }

    override func tearDown() {
        URLProtocol.unregisterClass(PokemonServiceStubURLProtocol.self)
        super.tearDown()
    }

    func testRequestPokemonReturnsSortedViewModels() async throws {
        // Arrange
        PokemonServiceStubURLProtocol.routes["/api/pokemon"] = .init(statusCode: 200, data: makeListJSON(ids: [3,1,2], base: "https://example.com/api/"))
        PokemonServiceStubURLProtocol.routes["/api/pokemon/1"] = .init(statusCode: 200, data: makeDetailJSON(id: 1))
        PokemonServiceStubURLProtocol.routes["/api/pokemon/2"] = .init(statusCode: 200, data: makeDetailJSON(id: 2))
        PokemonServiceStubURLProtocol.routes["/api/pokemon/3"] = .init(statusCode: 200, data: makeDetailJSON(id: 3))

        let service = Network.Service(server: .basic(baseURL: baseURL))
        let api = APIService(networkService: service, config: PokemonService.Config())
        let pokemonService = PokemonService(service: api)

        // Act
        let vms = try await pokemonService.requestPokemon()

        // Assert
        XCTAssertEqual(vms.map { $0.id }, [1,2,3])
        XCTAssertEqual(vms.first?.name, "Poke 1")
        XCTAssertEqual(vms.last?.name, "Poke 3")
    }

    func testRequestPokemonPropagatesDetailError() async {
        // List with one -> detail fails
        PokemonServiceStubURLProtocol.routes["/api/pokemon"] = .init(statusCode: 200, data: makeListJSON(ids: [1], base: "https://example.com/api/"))
        PokemonServiceStubURLProtocol.routes["/api/pokemon/1"] = .init(statusCode: 404, data: Data())

        let service = Network.Service(server: .basic(baseURL: baseURL))
        let api = APIService(networkService: service, config: PokemonService.Config())
        let pokemonService = PokemonService(service: api)

        do {
            _ = try await pokemonService.requestPokemon()
            XCTFail("Expected 404 error")
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
