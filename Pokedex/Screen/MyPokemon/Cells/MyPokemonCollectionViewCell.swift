//
//  MyPokemonCollectionViewCell.swift
//  Pokedex
//
//  Created by Fathureza Januarza on 08/08/24.
//

import UIKit
import RxSwift
import RxCocoa

final class MyPokemonCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "MyPokemonCollectionViewCell"
    
    private lazy var pokemonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    lazy var releaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Release", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var renameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Rename", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(pokemonImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(releaseButton)
        contentView.addSubview(renameButton)
        
        NSLayoutConstraint.activate([
            pokemonImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            pokemonImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pokemonImageView.widthAnchor.constraint(equalToConstant: 80),
            pokemonImageView.heightAnchor.constraint(equalToConstant: 80),
            
            nameLabel.topAnchor.constraint(equalTo: pokemonImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            releaseButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            releaseButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            releaseButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            renameButton.topAnchor.constraint(equalTo: releaseButton.bottomAnchor, constant: 8),
            renameButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            renameButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            renameButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with pokemon: CaughtPokemon) {
        nameLabel.text = pokemon.nickname
        if let url = URL(string: pokemon.url) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data else { return }
                DispatchQueue.main.async {
                    self?.pokemonImageView.image = UIImage(data: data)
                }
            }.resume()
        }
    }
}
