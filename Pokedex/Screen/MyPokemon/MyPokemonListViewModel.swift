//
//  MyPokemonListViewModel.swift
//  Pokedex
//
//  Created by Fathureza Januarza on 08/08/24.
//

import Foundation
import RxSwift
import RxCocoa

protocol MyPokemonListViewModelProtocol {
    var myPokemonList: Observable<[CaughtPokemon]> { get }
    var errorObservable: Observable<String> { get }
    
    func releasePokemon(at index: Int)
    func renamePokemon(at index: Int, newName: String)
    func fetchMyPokemonList()
}

final class MyPokemonListViewModel: MyPokemonListViewModelProtocol {
    
    private var myPokemonListRelay = BehaviorRelay<[CaughtPokemon]>(value: [])
    private var errorRelay = PublishSubject<String>()
    private let disposeBag = DisposeBag()
    
    init() {
        fetchMyPokemonList()
    }

    func fetchMyPokemonList() {
        myPokemonListRelay.accept(getMyPokemonList())
    }
    
    func releasePokemon(at index: Int) {
        let randomPrime = generateRandomPrime()
        
        if isPrime(randomPrime) {
            var currentList = myPokemonListRelay.value
            currentList.remove(at: index)
            myPokemonListRelay.accept(currentList)
            saveMyPokemonList(currentList)
        } else {
            errorRelay.onNext("Release failed. \(randomPrime) is not a prime number.")
        }
    }
    
    func renamePokemon(at index: Int, newName: String) {
        var currentList = myPokemonListRelay.value
        var pokemon = currentList[index]
        let fibonacci = generateFibonacci(pokemon.renameCount)
        pokemon.nickname = "\(newName)-\(fibonacci)"
        pokemon.renameCount += 1
        currentList[index] = pokemon
        myPokemonListRelay.accept(currentList)
        saveMyPokemonList(currentList)
    }
    
    private func getMyPokemonList() -> [CaughtPokemon] {
        guard let data = UserDefaults.standard.data(forKey: "myPokemonList"),
              let myPokemonList = try? JSONDecoder().decode([CaughtPokemon].self, from: data) else {
            return []
        }
        return myPokemonList
    }

    private func saveMyPokemonList(_ list: [CaughtPokemon]) {
        if let data = try? JSONEncoder().encode(list) {
            UserDefaults.standard.set(data, forKey: "myPokemonList")
        }
    }

    private func generateFibonacci(_ n: Int) -> Int {
        if n == 0 { return 0 }
        if n == 1 { return 1 }
        var a = 0
        var b = 1
        for _ in 2...n {
            let temp = a
            a = b
            b = temp + b
        }
        return b
    }

    private func isPrime(_ number: Int) -> Bool {
        guard number > 1 else { return false }
        for i in 2..<number {
            if number % i == 0 {
                return false
            }
        }
        return true
    }

    private func generateRandomPrime() -> Int {
        let primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]
        return primes.randomElement()!
    }
}

extension MyPokemonListViewModel {
    var myPokemonList: Observable<[CaughtPokemon]> {
        return myPokemonListRelay.asObservable()
    }
    
    var errorObservable: Observable<String> {
        return errorRelay.asObservable()
    }
}
