//
//  Onboarding.swift
//  BGCheck
//
//  Created by Andrey Zhelev on 13.11.2024.
//
import UIKit

class OnboardingViewController: UIViewController {
    
    private let minimumTitleLength = 6
    
    private let picture: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "BG"))
        return imageView
    }()
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.text = "Number:"
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }()
    private let pinLabel: UILabel = {
        let label = UILabel()
        label.text = "Pin:"
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    private let numberInputField: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .left
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .black
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 6
        textField.layer.masksToBounds = true
        textField.borderStyle = .line
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.8
        textField.text = UserDefaults.standard.string(forKey: "storedNumber")
        return textField
    }()
    
    private let pinInputField: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .left
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .black
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 6
        textField.layer.masksToBounds = true
        textField.borderStyle = .line
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.8
        textField.text = UserDefaults.standard.string(forKey: "storedPin")
        return textField
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .gray
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.8
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        updateButtonState()
    }
    
    @objc private func confirmButtonPressed() {
        UserDefaults.standard.set(numberInputField.text, forKey: "storedNumber")
        UserDefaults.standard.set(pinInputField.text, forKey: "storedPin")
        guard let window = self.view.window else { fatalError("Invalid Configuration") }
        window.rootViewController = MainViewController()
    }
    
    @objc private func updateButtonState() {
        confirmButton.isEnabled = numberInputField.text?.count ?? 0 >= minimumTitleLength && pinInputField.text?.count ?? 0 >= minimumTitleLength
        confirmButton.backgroundColor = confirmButton.isEnabled ? Colors.buttonActive : .gray
        confirmButton.setTitleColor(confirmButton.isEnabled
                                    ? .white
                                    : .black,
                                 for: .normal
        )
    }
    
    private func setUI() {
        self.view.backgroundColor = Colors.onboardingBg
        
        numberInputField.addTarget(self, action: #selector(updateButtonState), for: .editingChanged)
        pinInputField.addTarget(self, action: #selector(updateButtonState), for: .editingChanged)
        confirmButton.addTarget(self, action: #selector(confirmButtonPressed), for: .touchUpInside)
        
        for item in [picture, numberLabel, numberInputField, pinLabel, pinInputField, confirmButton] {
            item.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(item)
        }
        
        NSLayoutConstraint.activate([
        picture.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
        picture.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        picture.heightAnchor.constraint(equalTo: picture.widthAnchor),
        picture.heightAnchor.constraint(equalToConstant: 200),
        numberLabel.centerYAnchor.constraint(equalTo: numberInputField.centerYAnchor),
        numberLabel.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -50),
        numberInputField.topAnchor.constraint(equalTo: picture.bottomAnchor, constant: 40),
        numberInputField.leadingAnchor.constraint(equalTo: numberLabel.trailingAnchor, constant: 10),
        numberInputField.widthAnchor.constraint(equalToConstant: 130),
        pinLabel.centerYAnchor.constraint(equalTo: pinInputField.centerYAnchor),
        pinLabel.trailingAnchor.constraint(equalTo: numberLabel.trailingAnchor),
        pinInputField.topAnchor.constraint(equalTo: numberInputField.bottomAnchor, constant: 10),
        pinInputField.leadingAnchor.constraint(equalTo: numberInputField.leadingAnchor),
        pinInputField.widthAnchor.constraint(equalTo: numberInputField.widthAnchor),
        confirmButton.topAnchor.constraint(equalTo: pinLabel.bottomAnchor, constant: 50),
        confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        confirmButton.widthAnchor.constraint(equalToConstant: 200),
        confirmButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
