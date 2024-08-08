//
//  PokemonDetailViewModel.swift
//  Pokedex
//
//  Created by Fathureza Januarza on 08/08/24.
//

import Foundation
import RxSwift
import RxCocoa

protocol PokemonDetailViewModelProtocol {
    var pokemonDetail: Observable<PokemonDetail> { get }
    var catchResult: Observable<Bool> { get }
    var errorObservable: Observable<Error> { get }
    
    func catchPokemon()
    func saveCaughtPokemon(nickname: String)
}

final class PokemonDetailViewModel: PokemonDetailViewModelProtocol {
    
    private let disposeBag = DisposeBag()
    
    private var pokemonDetailRelay: BehaviorRelay<PokemonDetail>
    private var catchResultRelay = PublishSubject<Bool>()
    private var errorRelay = PublishSubject<Error>()
    
    init(pokemonDetail: PokemonDetail) {
        self.pokemonDetailRelay = BehaviorRelay<PokemonDetail>(value: pokemonDetail)
    }
    
    func saveCaughtPokemon(nickname: String) {
        let detail = pokemonDetailRelay.value
        
        let caughtPokemon = CaughtPokemon(name: detail.name, url: detail.sprites.front_default ?? "", nickname: nickname)
        var myPokemonList = getMyPokemonList()
        myPokemonList.append(caughtPokemon)
        
        if let data = try? JSONEncoder().encode(myPokemonList) {
            UserDefaults.standard.set(data, forKey: "myPokemonList")
        }
    }
    
    private func getMyPokemonList() -> [CaughtPokemon] {
        guard let data = UserDefaults.standard.data(forKey: "myPokemonList"),
              let myPokemonList = try? JSONDecoder().decode([CaughtPokemon].self, from: data) else {
            return []
        }
        return myPokemonList
    }
}

extension PokemonDetailViewModel {
    
    var pokemonDetail: Observable<PokemonDetail> {
        return pokemonDetailRelay.asObservable()
    }
    
    var catchResult: Observable<Bool> {
        return catchResultRelay.asObservable()
    }
    
    var errorObservable: Observable<Error> {
        return errorRelay.asObservable()
    }
    
    func catchPokemon() {
        let success = Int.random(in: 0..<100) < 50 
        catchResultRelay.onNext(success)
    }
}
