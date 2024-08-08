//
//  PokemonDetailViewController.swift
//  Pokedex
//
//  Created by Fathureza Januarza on 08/08/24.
//

import UIKit
import RxSwift

final class PokemonDetailViewController: UIViewController, CatchPokemonViewControllerDelegate {
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var pokemonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var movesLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var typesLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var catchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Catch Pokemon", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let viewModel: PokemonDetailViewModelProtocol
    private let disposeBag = DisposeBag()
    
    init(viewModel: PokemonDetailViewModelProtocol) {
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
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(pokemonImageView)
        contentView.addSubview(movesLabel)
        contentView.addSubview(typesLabel)
        contentView.addSubview(catchButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            pokemonImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            pokemonImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pokemonImageView.widthAnchor.constraint(equalToConstant: 150),
            pokemonImageView.heightAnchor.constraint(equalToConstant: 150),
            
            movesLabel.topAnchor.constraint(equalTo: pokemonImageView.bottomAnchor, constant: 20),
            movesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            movesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            typesLabel.topAnchor.constraint(equalTo: movesLabel.bottomAnchor, constant: 20),
            typesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            typesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            catchButton.topAnchor.constraint(equalTo: typesLabel.bottomAnchor, constant: 20),
            catchButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            catchButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupBindings() {
        viewModel.pokemonDetail
            .subscribe(onNext: { [weak self] detail in
                self?.configureView(with: detail)
            })
            .disposed(by: disposeBag)
        
        viewModel.catchResult
            .subscribe(onNext: { [weak self] success in
                if success {
                    self?.presentCatchPokemonViewController()
                } else {
                    self?.showAlert(title: "Failed", message: "The Pokemon escaped.")
                }
            })
            .disposed(by: disposeBag)
        
        catchButton.rx.tap
            .bind { [weak self] in
                self?.viewModel.catchPokemon()
            }
            .disposed(by: disposeBag)
        
        viewModel.errorObservable
            .subscribe(onNext: { [weak self] error in
                self?.showAlert(title: "Error", message: error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureView(with detail: PokemonDetail) {
        if let imageUrl = detail.sprites.front_default, let url = URL(string: imageUrl) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data else { return }
                DispatchQueue.main.async {
                    self?.pokemonImageView.image = UIImage(data: data)
                }
            }.resume()
        }
        
        movesLabel.text = "Moves: " + detail.moves.prefix(3).map { $0.move.name }.joined(separator: ", ")
        typesLabel.text = "Types: " + detail.types.map { $0.type.name }.joined(separator: ", ")
    }
    
    private func presentCatchPokemonViewController() {
        let catchPokemonViewController = CatchPokemonViewController()
        catchPokemonViewController.delegate = self
        catchPokemonViewController.modalPresentationStyle = .custom
        catchPokemonViewController.transitioningDelegate = catchPokemonViewController
        present(catchPokemonViewController, animated: true, completion: nil)
    }
    
    func didSaveNickname(_ nickname: String) {
        viewModel.saveCaughtPokemon(nickname: nickname)
        showAlert(title: "Saved", message: "Your Pokemon has been saved.")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}
