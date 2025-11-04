#if canImport(XCTest)
import XCTest
@testable import Pokemon

final class PokemonAPIModelsTests: XCTestCase {
    func testPokemonDecodingLimitsMovesToTen() throws {
        let json = """
        {
          "id": 25,
          "name": "pikachu",
          "weight": 60,
          "height": 4,
          "cries": { "latest": "https://sound.example/25.mp3" },
          "sprites": {
            "front_default": "https://img.example/front.png",
            "back_default": "https://img.example/back.png"
          },
          "abilities": [
            { "ability": { "name": "static", "url": "https://api/ability/static" } }
          ],
          "moves": [
            { "move": { "name": "thunder-shock", "url": "https://api/move/1" } },
            { "move": { "name": "quick-attack", "url": "https://api/move/2" } },
            { "move": { "name": "iron-tail", "url": "https://api/move/3" } },
            { "move": { "name": "volt-tackle", "url": "https://api/move/4" } },
            { "move": { "name": "thunderbolt", "url": "https://api/move/5" } },
            { "move": { "name": "thunder", "url": "https://api/move/6" } },
            { "move": { "name": "slam", "url": "https://api/move/7" } },
            { "move": { "name": "feint", "url": "https://api/move/8" } },
            { "move": { "name": "charge", "url": "https://api/move/9" } },
            { "move": { "name": "spark", "url": "https://api/move/10" } },
            { "move": { "name": "extra", "url": "https://api/move/11" } }
          ],
          "types": [ { "type": { "name": "electric", "url": "https://api/type/electric" } } ],
          "stats": [
            { "base_stat": 35, "stat": { "name": "hp", "url": "https://api/stat/hp" } }
          ]
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let pikachu = try decoder.decode(Pokemon.self, from: json)

        XCTAssertEqual(pikachu.id, 25)
        XCTAssertEqual(pikachu.name, "pikachu")
        XCTAssertEqual(pikachu.moves.count, 10, "Moves should be limited to 10 during decoding")
        XCTAssertEqual(pikachu.sprite.front, "https://img.example/front.png")
        XCTAssertEqual(pikachu.sprite.back, "https://img.example/back.png")
        XCTAssertEqual(pikachu.types.count, 1)
        XCTAssertEqual(pikachu.stats.count, 1)
        XCTAssertEqual(pikachu.cries.latest, "https://sound.example/25.mp3")
    }
}
#endif