#if canImport(XCTest)
import XCTest
@testable import Pokemon

final class PokemonViewModelTests: XCTestCase {
    func testComputedPropertiesFromModel() {
        let vm = PokemonViewModel(pokemon: .pikachu)
        XCTAssertEqual(vm.id, 0)
        XCTAssertEqual(vm.name, "Pika")
        XCTAssertEqual(vm.frontSprite, "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png")
        XCTAssertEqual(vm.backSprite, "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/25.png")

        XCTAssertTrue(vm.height.hasSuffix(" m"))
        XCTAssertTrue(vm.weight.hasSuffix(" kg"))

        XCTAssertTrue(vm.abilities.contains("Hp"))
        XCTAssertFalse(vm.moves.isEmpty)
        XCTAssertFalse(vm.types.isEmpty)
    }
}
#endif
