//
//  RenamePokemonViewController.swift
//  Pokedex
//
//  Created by Fathureza Januarza on 08/08/24.
//

import Foundation
import UIKit

protocol RenamePokemonViewControllerDelegate: AnyObject {
    func didSaveNewName(_ newName: String, for index: Int)
}

final class RenamePokemonViewController: UIViewController {
    
    weak var delegate: RenamePokemonViewControllerDelegate?
    var pokemonIndex: Int?
    
    private lazy var nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter New Nickname"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(nicknameTextField)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            nicknameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nicknameTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            nicknameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nicknameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            saveButton.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    @objc private func saveButtonTapped() {
        guard let newName = nicknameTextField.text, !newName.isEmpty, let index = pokemonIndex else { return }
        delegate?.didSaveNewName(newName, for: index)
        dismiss(animated: true, completion: nil)
    }
}
