//
//  PokemonMoyaTarget.swift
//  Pokedex
//
//  Created by Fathureza Januarza on 07/08/24.
//

import Moya

enum PokemonMoyaTarget {
    case fetchPokemons
    case fetchPokemonsWithURL(url: String)
    case fetchPokemonDetail(url: String)
}

extension PokemonMoyaTarget: TargetType {
    var baseURL: URL {
        switch self {
        case .fetchPokemons:
            return URL(string: "https://pokeapi.co/api/v2")!
        case .fetchPokemonDetail(let url):
            // Direct URL for fetching details
            return URL(string: url)!
        case .fetchPokemonsWithURL(let url):
            return URL(string: url)!
        }
    }

    var path: String {
        switch self {
        case .fetchPokemons:
            return "/pokemon"
        case .fetchPokemonDetail, .fetchPokemonsWithURL:
            return ""
        }
    }

    var method: Moya.Method {
        return .get
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        switch self {
        case .fetchPokemons:
            return .requestParameters(parameters: ["limit": 20, "offset": 0], encoding: URLEncoding.queryString)
        case .fetchPokemonsWithURL, .fetchPokemonDetail:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
