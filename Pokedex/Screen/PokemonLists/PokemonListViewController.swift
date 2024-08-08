//
//  PokemonListViewController.swift
//  Pokedex
//
//  Created by Fathureza Januarza on 07/08/24.
//

import UIKit
import RxSwift
import RxCocoa

final class PokemonListViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 160)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PokemonCollectionViewCell.self, forCellWithReuseIdentifier: PokemonCollectionViewCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private let viewModel: PokemonListViewModelProtocol
    private let disposeBag = DisposeBag()
    
    init(viewModel: PokemonListViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupBindings()
        viewModel.fetchPokemons()
        
        let myPokemonButton = UIBarButtonItem(title: "My Pokemon", style: .plain, target: self, action: #selector(myPokemonButtonTapped))
        navigationItem.rightBarButtonItem = myPokemonButton
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupBindings() {
        viewModel.completedFetchPokemon
            .subscribe(onNext: { [weak self] _ in
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)

        viewModel.isLoadingObservable
            .subscribe(onNext: { isLoading in
                print("Loading: \(isLoading)")
            })
            .disposed(by: disposeBag)

        viewModel.errorObservable
            .subscribe(onNext: { error in
                print("Error: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func myPokemonButtonTapped() {
        let myPokemonListViewController = MyPokemonListViewController()
        navigationController?.pushViewController(myPokemonListViewController, animated: true)
    }
}

extension PokemonListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.pokemonCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PokemonCollectionViewCell.identifier, for: indexPath) as! PokemonCollectionViewCell
        let pokemon = viewModel.pokemonData[indexPath.row]
        let detail = viewModel.pokemonDetails[indexPath.row]
        cell.configure(with: pokemon, detail: detail)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detail = viewModel.pokemonDetails[indexPath.row]
        let detailViewModel = PokemonDetailViewModel(pokemonDetail: detail)
        let detailViewController = PokemonDetailViewController(viewModel: detailViewModel)
        navigationController?.pushViewController(detailViewController, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.height {
            viewModel.loadMorePokemonsIfNeeded(currentItemIndex: collectionView.indexPathsForVisibleItems.last?.row ?? 0)
        }
    }
}
