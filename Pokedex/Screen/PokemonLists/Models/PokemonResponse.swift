//
//  Pokemons.swift
//  Pokedex
//
//  Created by Fathureza Januarza on 07/08/24.
//

import Foundation

struct Pokemon: Codable {
    let name: String
    let url: String
}

struct PokemonResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Pokemon]
}

struct PokemonDetail: Codable {
    let name: String
    let sprites: Sprites
    let moves: [Move]
    let types: [TypeElement]
}

struct Sprites: Codable {
    let front_default: String?
}

struct Move: Codable {
    let move: MoveDetail
}

struct MoveDetail: Codable {
    let name: String
}

struct TypeElement: Codable {
    let type: TypeDetail
}

struct TypeDetail: Codable {
    let name: String
}
