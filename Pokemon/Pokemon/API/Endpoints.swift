//
//  Endpoint.swift
//  Pokemon
//
//  Created by Bern on 2025/11/2.
//

import Foundation

/// An enumeration list representing all possible endpoints of the backend
enum Endpoint {
    case pokemonDetails(String)
    case pokemon
}

// MARK: - EndpointType
extension Endpoint: EndpointType {
    var path: String {
        switch self {
            case .pokemonDetails(let id): return "pokemon/\(id)"
            case .pokemon: return "pokemon"
        }
    }
}
