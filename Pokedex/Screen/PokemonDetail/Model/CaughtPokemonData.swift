//
//  CaughtPokemonData.swift
//  Pokedex
//
//  Created by Fathureza Januarza on 08/08/24.
//

import Foundation

struct CaughtPokemon: Codable {
    let name: String
    let url: String
    var nickname: String
    var renameCount: Int = 0
}
