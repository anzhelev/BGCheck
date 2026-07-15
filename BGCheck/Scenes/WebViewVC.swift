import UIKit
import WebKit

class WebViewVC: UIViewController {
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private var currentLoadedPageName: String?
    private var pageLoaded: Bool = false
    private var autoCheck: Bool = false
    
    private var lastCaseChecked: Int = 0
    private var currentMessage: String? {
        didSet {
            updateCaseHistory()
        }
    }
    
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
        
        webView.backgroundColor = .backgroundPrimary
        webView.navigationDelegate = self
        webView.overrideUserInterfaceStyle = .light
        
        return webView
    }()
    
    private lazy var cases: [Case] = {
        return loadCases()
    }()
    
    private lazy var reloadButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(reloadButtonAction), for: .touchUpInside)
        button.setTitle(.Localized.webViewVCButtonReload, for: .normal)
        button.backgroundColor = .buttonsSecondary
        button.layer.borderWidth = .borderWidth1
        button.layer.borderColor = .buttonsBorderCGC
        button.setTitleColor(.textSecondary, for: .normal)
        button.titleLabel?.font = .buttonsLabelFontSecondary
        button.layer.masksToBounds = true
        button.layer.cornerRadius = .cornerRadius16
        return button
    }()
    
    private lazy var settingsButton: UIButton = {
        guard let image = UIImage.webViewControllerSettingsButton else {
            return UIButton()
        }
        let button = UIButton.systemButton(with: image, target: self, action: #selector(self.settingsButtonAction))
        button.addTarget(self, action: #selector(settingsButtonAction), for: .touchUpInside)
        button.tintColor = .buttonsSecondary
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
        lastCaseChecked = sender.tag
        let numberInputJavaScript = "\(JSConstants.numberInputJavaScript) '\(cases[lastCaseChecked].caseNumber ?? "")';"
        let pinInputJavaScript = "\(JSConstants.pinInputJavaScript) '\(cases[lastCaseChecked].pin ?? "")';"
        self.webView.evaluateJavaScript(numberInputJavaScript, completionHandler: {(res, error) -> Void in })
        self.webView.evaluateJavaScript(pinInputJavaScript, completionHandler: {(res, error) -> Void in })
        self.webView.evaluateJavaScript(JSConstants.clickOnButtonJavaScript, completionHandler: {(res, error) -> Void in })
    }
    
    @objc private func reloadButtonAction() {
        loadWebPage()
    }
    
    @objc private func settingsButtonAction() {
        guard let window = self.view.window else { fatalError("Invalid Configuration") }
        window.rootViewController = UINavigationController(rootViewController: OnboardingVC())
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
            reloadButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: .spacing10),
            reloadButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -.spacing10),
            reloadButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.spacing8),
            reloadButton.heightAnchor.constraint(equalToConstant: .buttonsHeight48),
            
            buttonsStackView.bottomAnchor.constraint(equalTo: reloadButton.topAnchor, constant: -.spacing8),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: .spacing10),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -.spacing10),
            buttonsStackView.heightAnchor.constraint(equalToConstant: .buttonsHeight48),
            
            settingsButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            settingsButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: .buttonsHeight52),
            settingsButton.heightAnchor.constraint(equalTo: settingsButton.widthAnchor),
            
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -.spacing10),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            progressView.topAnchor.constraint(equalTo: webView.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: .borderWidth2)
        ])
    }
    
    private func setCheckCaseButton(tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = tag
        let buttonTitle = cases[tag].caseName?.isEmpty ?? true
            ? "\(String.Localized.webViewVCLabelCase) \(tag + 1)"
            : cases[tag].caseName
        button.setTitle(buttonTitle, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .buttonsLabelFontTertiary
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5
        button.titleLabel?.lineBreakMode = .byClipping
        button.titleLabel?.numberOfLines = 2
        button.backgroundColor = .buttonsSecondary
        button.layer.borderWidth = .borderWidth1
        button.layer.borderColor = .buttonsBorderCGC
        button.setTitleColor(.textSecondary, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = .cornerRadius16
        
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
        stackView.spacing = .spacing4
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
        var caseNumber: String?
        var pin: String?
        var history: [HistoryRecord] = []
        
        for row in 0...4 {
            caseName = UserDefaults.standard.string(forKey: "case\(row)Name")
            caseNumber = UserDefaults.standard.string(forKey: "case\(row)Number")
            pin = UserDefaults.standard.string(forKey: "case\(row)Pin")
            if let savedData = UserDefaults.standard.data(forKey: "case\(row)History"),
               let records = try? decoder.decode([HistoryRecord].self, from: savedData) {
                history = records
            }
            if caseName != nil || caseNumber != nil || pin != nil {
                cases.append(.init(caseName: caseName, caseNumber: caseNumber, pin: pin, history: history))
            }
            
        }
        return cases
    }
    
    private func updateCaseHistory() {
        switch currentMessage {
        case nil, "":
            break
        case cases[lastCaseChecked].history?.last?.record ?? "":
            break
        default:
            var newHistory: [HistoryRecord] = cases[lastCaseChecked].history ?? []
            newHistory.append(.init(date: Date(), record: currentMessage ?? ""))
            if let encoded = try? encoder.encode(newHistory) {
                UserDefaults.standard.set(encoded, forKey: "case\(lastCaseChecked)History")
            }
            cases = loadCases()
        }
    }
    
    private func addMessagesSearchScript() {
        let script = WKUserScript(source: JSConstants.checkMessagesScript,
                                  injectionTime: .atDocumentEnd,
                                  forMainFrameOnly: false)
        
        webView.configuration.userContentController.addUserScript(script)
        webView.configuration.userContentController.add(self, name: "checkMessagesHandler")
    }
    
    private func addLoadCompleteScript() {
        let script = WKUserScript(source: JSConstants.loadCompleteScript,
                                  injectionTime: .atDocumentEnd,
                                  forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(script)
        webView.configuration.userContentController.add(self, name: "pageLoadHandler")
    }
}

extension WebViewVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("@@@ load error: \(error.localizedDescription)")
    }
}

extension WebViewVC: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        switch message.name {
            
        case "checkMessagesHandler":
            if let data = message.body as? [String: Any],
               let messages = data["messages"] as? [String] {
                currentMessage = messages.joined(separator: "\n")
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

extension WebViewVC: ClickTrackingWebViewDelegate {
    func clickTracked(on point: CGPoint) {
    }
}
