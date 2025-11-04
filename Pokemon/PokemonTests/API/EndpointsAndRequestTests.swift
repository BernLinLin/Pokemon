#if canImport(XCTest)
import XCTest
@testable import Pokemon

final class EndpointsAndRequestTests: XCTestCase {
    func testEndpointPaths() {
        XCTAssertEqual(Endpoint.pokemon.path, "pokemon")
        XCTAssertEqual(Endpoint.pokemonDetails("25").path, "pokemon/25")
    }

    func testPokemonRequestBasics() {
        let list = PokemonRequest.pokemon
        XCTAssertEqual(list.httpMethod, .get)
        XCTAssertEqual(list.encoding, .query)

        // parameters contain limit=1000 for list
        XCTAssertEqual(list.parameters[ParameterKey.limit.rawValue], "10")

        // endpoint type
        XCTAssertEqual((list.endpoint as! Endpoint).path, Endpoint.pokemon.path)

        let details = PokemonRequest.details("25")
        XCTAssertEqual(details.httpMethod, .get)
        XCTAssertEqual(details.encoding, .query)
        XCTAssertTrue(details.parameters.isEmpty)
        XCTAssertEqual((details.endpoint as! Endpoint).path, Endpoint.pokemonDetails("25").path)
    }
}
#endif
