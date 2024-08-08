//
//  MyPokemonListViewController.swift
//  Pokedex
//
//  Created by Fathureza Januarza on 08/08/24.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class MyPokemonListViewController: UIViewController {
    
    private let viewModel: MyPokemonListViewModelProtocol
    private let disposeBag = DisposeBag()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 150)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MyPokemonCollectionViewCell.self, forCellWithReuseIdentifier: MyPokemonCollectionViewCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private var myPokemonList: [CaughtPokemon] = []
    
    init(viewModel: MyPokemonListViewModelProtocol = MyPokemonListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.fetchMyPokemonList()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "My Pokemon List"
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.myPokemonList
            .subscribe(onNext: { [weak self] pokemonList in
                self?.myPokemonList = pokemonList
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.errorObservable
            .subscribe(onNext: { [weak self] error in
                self?.showAlert(for: error)
            })
            .disposed(by: disposeBag)
    }
    
    private func presentRenameViewController(for index: Int) {
        let renameVC = RenamePokemonViewController()
        renameVC.delegate = self
        renameVC.pokemonIndex = index
        renameVC.modalPresentationStyle = .overFullScreen
        present(renameVC, animated: true, completion: nil)
    }
    
    private func showAlert(for error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension MyPokemonListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myPokemonList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyPokemonCollectionViewCell.identifier, for: indexPath) as! MyPokemonCollectionViewCell
        let pokemon = myPokemonList[indexPath.row]
        cell.configure(with: pokemon)
        
        cell.releaseButton.addTarget(self, action: #selector(releaseButtonTapped(_:)), for: .touchUpInside)
        cell.releaseButton.tag = indexPath.row
        
        cell.renameButton.addTarget(self, action: #selector(renameButtonTapped(_:)), for: .touchUpInside)
        cell.renameButton.tag = indexPath.row
        
        return cell
    }
    
    @objc private func releaseButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        viewModel.releasePokemon(at: index)
    }
    
    @objc private func renameButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        presentRenameViewController(for: index)
    }
}

extension MyPokemonListViewController: RenamePokemonViewControllerDelegate {
    func didSaveNewName(_ newName: String, for index: Int) {
        viewModel.renamePokemon(at: index, newName: newName)
    }
}
