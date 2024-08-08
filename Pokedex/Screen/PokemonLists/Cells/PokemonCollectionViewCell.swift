//
//  PokemonCollectionViewCell.swift
//  Pokedex
//
//  Created by Fathureza Januarza on 07/08/24.
//

import UIKit

final class PokemonCollectionViewCell: UICollectionViewCell {
    static let identifier = "PokemonCollectionViewCell"

    private lazy var pokemonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 50 // Making the image view circular
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var pokemonNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .darkGray
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        styleCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(pokemonImageView)
        contentView.addSubview(pokemonNameLabel)

        NSLayoutConstraint.activate([
            pokemonImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            pokemonImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pokemonImageView.widthAnchor.constraint(equalToConstant: 100),
            pokemonImageView.heightAnchor.constraint(equalToConstant: 100),

            pokemonNameLabel.topAnchor.constraint(equalTo: pokemonImageView.bottomAnchor, constant: 8),
            pokemonNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            pokemonNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            pokemonNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    private func styleCell() {
        contentView.layer.cornerRadius = 10
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowOffset = CGSize(width: 0, height: 3)
        contentView.layer.shadowRadius = 5
        contentView.layer.masksToBounds = false
        contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)
    }

    func configure(with pokemon: Pokemon, detail: PokemonDetail) {
        pokemonNameLabel.text = pokemon.name.capitalized
        if let imageUrl = detail.sprites.front_default, let url = URL(string: imageUrl) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self.pokemonImageView.image = UIImage(data: data)
                }
            }.resume()
        }
    }
}
