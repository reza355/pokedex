//
//  NetworkService.swift
//  Pokedex
//
//  Created by Fathureza Januarza on 07/08/24.
//

import Moya
import RxSwift

protocol NetworkServiceProtocol {
    func fetchPokemons(url: String?) -> Single<PokemonResponse>
    func fetchPokemonDetail(url: String) -> Single<PokemonDetail>
}

final class NetworkService: NetworkServiceProtocol {
    private let provider = MoyaProvider<PokemonMoyaTarget>(plugins: [NetworkLoggerPlugin()])

    func fetchPokemons(url: String?) -> Single<PokemonResponse> {
        let target: PokemonMoyaTarget
        if let url = url {
            target = .fetchPokemonsWithURL(url: url)
        } else {
            target = .fetchPokemons
        }
        return provider.rx.request(target)
            .filterSuccessfulStatusCodes()
            .map(PokemonResponse.self)
            .do(onSuccess: { response in
                print("Successfully fetched pokemons: \(response.results.map { $0.name })")
            }, onError: { error in
                if let moyaError = error as? MoyaError {
                    switch moyaError {
                    case .statusCode(let response):
                        print("Status code error: \(response.statusCode)")
                    case .underlying(let nsError, _):
                        print("Underlying error: \(nsError.localizedDescription)")
                    default:
                        print("Other error: \(moyaError.localizedDescription)")
                    }
                } else {
                    print("Failed to fetch pokemons with error: \(error.localizedDescription)")
                }
            })
    }

    func fetchPokemonDetail(url: String) -> Single<PokemonDetail> {
        return provider.rx.request(.fetchPokemonDetail(url: url))
            .filterSuccessfulStatusCodes()
            .map(PokemonDetail.self)
            .do(onSuccess: { detail in
                print("Successfully fetched pokemon detail: \(detail)")
            }, onError: { error in
                if let moyaError = error as? MoyaError {
                    switch moyaError {
                    case .statusCode(let response):
                        print("Status code error: \(response.statusCode) for URL: \(url)")
                    case .underlying(let nsError, _):
                        print("Underlying error: \(nsError.localizedDescription) for URL: \(url)")
                    default:
                        print("Other error: \(moyaError.localizedDescription) for URL: \(url)")
                    }
                } else {
                    print("Failed to fetch pokemon detail with error: \(error.localizedDescription) for URL: \(url)")
                }
            })
    }
}
