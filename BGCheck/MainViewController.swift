//
//  ViewController.swift
//  BGCheck
//
//  Created by Andrey Zhelev on 30.07.2024.
//
import UIKit
import WebKit

class MainViewController: UIViewController {
    
    private lazy var progressView: UIProgressView = {
        var progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = .orange
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        return progressView
    }()
    
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "consoleLog")
        config.userContentController = userContentController
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        return webView
    }()
    
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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
            
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.progressView.alpha = 0
                })
            } else {
                progressView.alpha = 1
            }
        }
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
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
        }
        
        [checkButton, reloadButton, webView, resetButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        webView.addSubview(progressView)
        
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
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            progressView.topAnchor.constraint(equalTo: webView.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    
    private func loadWebPage() {
        if let url = URL(string: Constants.url) {
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }
    }
    
    private func checkPass() {
        webView.evaluateJavaScript("""
            const elements = Array.from(document.querySelectorAll('*')).filter(element => {
                const rect = element.getBoundingClientRect();
                const ratio = rect.width / rect.height
                return rect.width >= 250 && rect.width <= 400 && ratio >= 4.45 && ratio <= 4.65;
            });
            
            elements.forEach(
                element => {
            
            const rect = element.getBoundingClientRect();
            const x = (rect.left + rect.width / 10);
            const y = rect.top + rect.height / 2;

            const touch = new Touch({
                identifier: Date.now(),
                target: element,
                clientX: x,
                clientY: y, 
                screenX: x,
                screenY: y,
                pageX: x,
                pageY: y,
                radiusX: 5,
                radiusY: 5,
                rotationAngle: 0,
                force: 1
            });
        
            const touchStartEvent = new TouchEvent('touchstart', {
                bubbles: true,
                cancelable: true,
                touches: [touch],
                targetTouches: [touch],
                changedTouches: [touch]
            });
        
            const touchEndEvent = new TouchEvent('touchend', {
                bubbles: true,
                cancelable: true,
                touches: [],
                targetTouches: [],
                changedTouches: [touch]
            });
        
            const targetElement = document.elementFromPoint(x, y);
        
            if (targetElement) {
                targetElement.dispatchEvent(touchStartEvent);
                targetElement.dispatchEvent(touchEndEvent);
                const mess = {
                    message: "элемент:", 
                    left: String(targetElement.id), 
                    top: "Тап выполнен", 
                    x: String(x),
                    y: String(y)
                    };
                window.webkit.messageHandlers.consoleLog.postMessage(mess);
                }
            });    
        """) { result, error in
            if let error = error {
                print("@@@ Ошибка: \(error.localizedDescription)")
            } else {
                print("@@@ Тап по координатам выполнен")
            }
        }
    }
}

extension MainViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
        //            self.checkPass()
        //        }
    }
    
    // Обрабатываем ошибки загрузки
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("@@@ Ошибка загрузки: \(error.localizedDescription)")
    }
}

extension MainViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "consoleLog", let messageBody = message.body as? [String: Any] {
            let messageText = messageBody["message"] as? String ?? ""
            let left = messageBody["left"] as? String ?? ""
            let top = messageBody["top"] as? String ?? ""
            let xCoord = messageBody["x"] as? String ?? "-"
            let yCoord = messageBody["y"] as? String ?? "-"
            print("@@@ JavaScript: \(messageText) (\(left),\(top)), (\(xCoord), \(yCoord))")
        }
    }
}
