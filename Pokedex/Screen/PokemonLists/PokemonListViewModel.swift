//
//  PokemonListViewModel.swift
//  Pokedex
//
//  Created by Fathureza Januarza on 07/08/24.
//

import Foundation
import RxSwift
import RxCocoa

protocol PokemonListViewModelProtocol {
    var completedFetchPokemon: Observable<Void> { get }
    var isLoadingObservable: Observable<Bool> { get }
    var errorObservable: Observable<Error> { get }
    
    var pokemonCount: Int { get }
    var pokemonData: [Pokemon] { get }
    var pokemonDetails: [PokemonDetail] { get }
    
    func fetchPokemons()
    func loadMorePokemonsIfNeeded(currentItemIndex: Int)
}

final class PokemonListViewModel: PokemonListViewModelProtocol {
    
    private var networkService: NetworkServiceProtocol
    private var nextURL: String?
    
    private var pokemonRelay: BehaviorRelay<[Pokemon]>
    private var pokemonDetailsRelay: BehaviorRelay<[PokemonDetail]>
    private var isLoading: BehaviorRelay<Bool>
    private var error: PublishSubject<Error>
    
    private let disposeBag = DisposeBag()
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
        self.pokemonRelay = BehaviorRelay<[Pokemon]>(value: [])
        self.pokemonDetailsRelay = BehaviorRelay<[PokemonDetail]>(value: [])
        self.isLoading = BehaviorRelay<Bool>(value: false)
        self.error = PublishSubject<Error>()
    }

    func fetchPokemons() {
        isLoading.accept(true)
        networkService.fetchPokemons(url: nextURL)
            .flatMap { [weak self] response -> Single<[PokemonDetail]> in
                guard let self = self else { return .never() }
                self.nextURL = response.next
                let pokemonDetailsObservables = response.results.map { self.networkService.fetchPokemonDetail(url: $0.url) }
                return Single.zip(pokemonDetailsObservables)
            }
            .subscribe(onSuccess: { [weak self] details in
                guard let self = self else { return }
                let updatedPokemons = self.pokemonRelay.value + details.map { Pokemon(name: $0.name, url: $0.sprites.front_default ?? "") }
                self.pokemonRelay.accept(updatedPokemons)
                self.pokemonDetailsRelay.accept(self.pokemonDetailsRelay.value + details)
                self.isLoading.accept(false)
            }, onFailure: { [weak self] error in
                self?.error.onNext(error)
                self?.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }

    func loadMorePokemonsIfNeeded(currentItemIndex: Int) {
        guard currentItemIndex >= pokemonRelay.value.count - 1 else { return }
        guard nextURL != nil else { return }
        fetchPokemons()
    }
}

extension PokemonListViewModel {
    var completedFetchPokemon: Observable<Void> {
        return Observable.combineLatest(pokemonRelay.asObservable(), pokemonDetailsRelay.asObservable())
            .asObservable()
            .map { _ in }
            .observe(on: MainScheduler.instance)
    }
    
    var pokemonCount: Int {
        return pokemonRelay.value.count
    }
    
    var pokemonData: [Pokemon] {
        return pokemonRelay.value
    }
    
    var pokemonDetails: [PokemonDetail] {
        return pokemonDetailsRelay.value
    }
    
    var isLoadingObservable: Observable<Bool> {
        return isLoading
            .asObservable()
            .observe(on: MainScheduler.instance)
    }
    
    var errorObservable: Observable<Error> {
        return error
            .asObservable()
            .observe(on: MainScheduler.instance)
    }
}
