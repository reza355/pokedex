//
//  CatchPokemonViewController.swift
//  Pokedex
//
//  Created by Fathureza Januarza on 08/08/24.
//

import Foundation
import UIKit

protocol CatchPokemonViewControllerDelegate: AnyObject {
    func didSaveNickname(_ nickname: String)
}

final class CatchPokemonViewController: UIViewController {
    
    weak var delegate: CatchPokemonViewControllerDelegate?
    
    private lazy var nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Nickname"
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
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        
        view.addSubview(nicknameTextField)
        view.addSubview(saveButton)
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            nicknameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nicknameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            nicknameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nicknameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            saveButton.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            closeButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    @objc private func saveButtonTapped() {
        guard let nickname = nicknameTextField.text, !nickname.isEmpty else { return }
        delegate?.didSaveNickname(nickname)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

extension CatchPokemonViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfHeightPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
