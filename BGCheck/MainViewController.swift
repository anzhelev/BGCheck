//
//  ViewController.swift
//  BGCheck
//
//  Created by Andrey Zhelev on 30.07.2024.
//

import UIKit
import WebKit

class MainViewController: UIViewController {
    private var webView = WKWebView()
    
    private lazy var checkButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(checkButtonAction), for: .touchUpInside)
        button.setTitle("Проверить", for: .normal)
        return button
    }()
    
    private lazy var reloadButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(reloadButtonAction), for: .touchUpInside)
        button.setTitle("Обновить", for: .normal)
        return button
    }()
    
    private lazy var resetButton: UIButton = {
        guard let image = UIImage(systemName: "gearshape.fill") else {
            return UIButton()
        }
        let button = UIButton.systemButton(with: image, target: self, action: #selector(self.resetButtonAction))
        button.addTarget(self, action: #selector(resetButtonAction), for: .touchUpInside)
        button.tintColor = .darkGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        loadWebPage()
    }
    
    @objc private func checkButtonAction() {
        self.webView.evaluateJavaScript(Constants.numberInputJavaScript, completionHandler: {(res, error) -> Void in })
        self.webView.evaluateJavaScript(Constants.pinInputJavaScript, completionHandler: {(res, error) -> Void in })
        self.webView.evaluateJavaScript(Constants.clickOnButtonJavaScript, completionHandler: {(res, error) -> Void in })
    }
    
    @objc private func reloadButtonAction() {
        loadWebPage()
    }
    
    @objc private func resetButtonAction() {
        guard let window = self.view.window else { fatalError("Invalid Configuration") }
        window.rootViewController = OnboardingViewController()
    }
    
    private func setUI() {
        for item in [checkButton, reloadButton] {
            item.backgroundColor = .orange
            item.layer.borderWidth = 1
            item.layer.borderColor = UIColor.gray.cgColor
            item.setTitleColor(.white, for: .normal)
            item.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            item.layer.masksToBounds = true
            item.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(item)
        }
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        view.addSubview(resetButton)
        
        NSLayoutConstraint.activate([
            checkButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            checkButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            checkButton.trailingAnchor.constraint(equalTo: view.centerXAnchor),
            checkButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            reloadButton.topAnchor.constraint(equalTo: checkButton.topAnchor),
            reloadButton.leadingAnchor.constraint(equalTo: view.centerXAnchor),
            reloadButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            reloadButton.bottomAnchor.constraint(equalTo: checkButton.bottomAnchor),
            resetButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            resetButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            resetButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            resetButton.widthAnchor.constraint(equalToConstant: 50),
            resetButton.heightAnchor.constraint(equalTo: resetButton.widthAnchor),
            
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: checkButton.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }

    private func loadWebPage() {
        if let url = URL(string: Constants.url) {
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }
    }
}
