import UIKit
import WebKit

class MainViewController: UIViewController {
    private var currentLoadedPageName: String?
    private var pageLoaded: Bool = false
    private var autoCheck: Bool = false
    
    private lazy var progressView: UIProgressView = {
        var progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = .orange
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        return progressView
    }()
    
    private lazy var webView: WKWebView = {
        let userContentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        let webView = ClickTrackingWebView(frame: .zero, configuration: config, delegate: self)
        
        webView.backgroundColor = .white
        webView.navigationDelegate = self
        
        return webView
    }()
    
    private lazy var cases: [Case] = {
        return loadCases()
    }()
    
    private lazy var reloadButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(reloadButtonAction), for: .touchUpInside)
        button.setTitle("Reload page", for: .normal)
        button.backgroundColor = .orange
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 12
        return button
    }()
    
    private lazy var settingsButton: UIButton = {
        guard let image = UIImage(systemName: "gearshape.fill") else {
            return UIButton()
        }
        let button = UIButton.systemButton(with: image, target: self, action: #selector(self.settingsButtonAction))
        button.addTarget(self, action: #selector(settingsButtonAction), for: .touchUpInside)
        button.tintColor = .orange
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        addMessagesSearchScript()
        addLoadCompleteScript()
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
    
    @objc private func checkButtonAction(_ sender: UIButton) {
        let numberInputJavaScript = "\(JavaScriptConstants.numberInputJavaScript) '\(cases[sender.tag].caseNumber ?? "")';"
        let pinInputJavaScript = "\(JavaScriptConstants.pinInputJavaScript) '\(cases[sender.tag].pin ?? "")';"
        self.webView.evaluateJavaScript(numberInputJavaScript, completionHandler: {(res, error) -> Void in })
        self.webView.evaluateJavaScript(pinInputJavaScript, completionHandler: {(res, error) -> Void in })
        self.webView.evaluateJavaScript(JavaScriptConstants.clickOnButtonJavaScript, completionHandler: {(res, error) -> Void in })
    }
    
    @objc private func reloadButtonAction() {
        loadWebPage()
    }
    
    @objc private func settingsButtonAction() {
        guard let window = self.view.window else { fatalError("Invalid Configuration") }
        window.rootViewController = OnboardingVC()
    }
    
    private func setUI() {
        view.backgroundColor = .white
        let buttonsStackView = setCaseButtonsStackView()
        [webView, settingsButton, buttonsStackView, reloadButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        webView.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            reloadButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            reloadButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            reloadButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -6),
            reloadButton.heightAnchor.constraint(equalToConstant: 40),
            
            buttonsStackView.bottomAnchor.constraint(equalTo: reloadButton.topAnchor, constant: -6),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 40),
            
            settingsButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            settingsButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            settingsButton.widthAnchor.constraint(equalToConstant: 50),
            settingsButton.heightAnchor.constraint(equalTo: settingsButton.widthAnchor),
            
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -10),
            //webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            progressView.topAnchor.constraint(equalTo: webView.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    
    private func setCheckCaseButton(tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = tag
        button.setTitle("Case \(tag + 1)", for: .normal)
        
        button.backgroundColor = .orange
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 12
        
        button.addTarget(self, action: #selector(checkButtonAction(_:)), for: .touchUpInside)
        return button
    }
    
    private func setCaseButtonsStackView() -> UIStackView {
        let subviews: [UIView] = cases.enumerated().map {
            setCheckCaseButton(tag: $0.offset)
        }
        
        let stackView = UIStackView(arrangedSubviews: subviews)
        stackView.backgroundColor = .clear
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }
    
    private func loadWebPage() {
        if let url = URL(string: WebConstants.mjcUrl) {
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }
    }
    
    private func loadCases() -> [Case] {
        var cases: [Case] = []
        var caseName: String?
        var pin: String?
        for caseNumber in 0...4 {
            caseName = UserDefaults.standard.string(forKey: "case\(caseNumber)Number")
            pin = UserDefaults.standard.string(forKey: "case\(caseNumber)Pin")
            if caseName != nil || pin != nil {
                cases.append(.init(caseNumber: caseName, pin: pin))
            }
        }
        return cases
    }
    
    private func addMessagesSearchScript() {
        let script = WKUserScript(source: JavaScriptConstants.checkMessagesScript,
                                  injectionTime: .atDocumentEnd,
                                  forMainFrameOnly: false)
        
        webView.configuration.userContentController.addUserScript(script)
        webView.configuration.userContentController.add(self, name: "checkMessagesHandler")
    }
    
    private func addLoadCompleteScript() {
        let script = WKUserScript(source: JavaScriptConstants.loadCompleteScript,
                                  injectionTime: .atDocumentEnd,
                                  forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(script)
        webView.configuration.userContentController.add(self, name: "pageLoadHandler")
    }
}

extension MainViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("@@@ load error: \(error.localizedDescription)")
    }
}

extension MainViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        switch message.name {
            
        case "checkMessagesHandler":
            if let data = message.body as? [String: Any],
               let messages = data["messages"] as? [String] {
                print("@@@:", messages.joined(separator: "\n@@@: "))
            }
            
        case "pageLoadHandler":
            if webView.title ?? "" == WebConstants.finalPageName {
                pageLoaded = true
                print("@@@: page loaded:", webView.title ?? "")
            }
            
        default:
            break
        }
    }
}

extension MainViewController: ClickTrackingWebViewDelegate {
    func clickTracked(on point: CGPoint) {
    }
}
