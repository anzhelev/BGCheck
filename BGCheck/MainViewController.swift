import UIKit
import WebKit

class MainViewController: UIViewController {
    
    private enum Constants {
        static let mjcUrl = "https://publicbg.mjs.bg/BgInfo"
        static let numberInputJavaScript = "document.getElementById('reqNun').value ="
        static let pinInputJavaScript = "document.getElementById('pin').value ="
        static let inputTagName: String = "INPUT"
        static let inputpartitialID: String = "cf-chl-widget"
        static let finalPageName: String = "Дирекция 'Българско гражданство'"
        
        static let clickOnButtonJavaScript = "document.getElementsByTagName('button')[0].click();"
    }
    
    private let tagName: String = "INPUT"
    private let partitialID: String = "cf-chl-widget"
    private var currentLoadedPageName: String?
    private var loadingFinished: Bool = false {
        didSet {
            widgetLoaded = false
            elementsLoaded = false
        }
    }
    
    private var elementsLoaded: Bool = false {
        didSet {
            if elementsLoaded {
                widgetLoaded = false
            }
        }
    }
    
    private var widgetLoaded: Bool = false {
        didSet {
            if widgetLoaded {
                print ("@@@ Все готово!")
            }
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
        addPartialIdScript()
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
        let numberInputJavaScript = "\(Constants.numberInputJavaScript) '\(cases[sender.tag].caseNumber ?? "")';"
        let pinInputJavaScript = "\(Constants.pinInputJavaScript) '\(cases[sender.tag].pin ?? "")';"
        self.webView.evaluateJavaScript(numberInputJavaScript, completionHandler: {(res, error) -> Void in })
        self.webView.evaluateJavaScript(pinInputJavaScript, completionHandler: {(res, error) -> Void in })
        self.webView.evaluateJavaScript(Constants.clickOnButtonJavaScript, completionHandler: {(res, error) -> Void in })
    }
    
    @objc private func reloadButtonAction() {
        loadWebPage()
        //
        //        webView.evaluateJavaScript("document.querySelector('input[type=\"checkbox\"]') !== null") { (result, error) in
        //            if let hasCheckbox = result as? Bool {
        //                if hasCheckbox {
        //                    print("@@@ На странице есть хотя бы один чекбокс")
        //                } else {
        //                    print("@@@ Чекбоксов не найдено")
        //                }
        //            } else if let error = error {
        //                print("Ошибка при выполнении JavaScript: \(error.localizedDescription)")
        //            }
        //        }
        
        //        let js = """
        //        var elements = document.getElementsByTagName('*');
        //        var result = [];
        //        for (var i = 0; i < elements.length; i++) {
        //            result.push({
        //                tag: elements[i].tagName,
        //                id: elements[i].id || null,
        //                class: elements[i].className || null
        //            });
        //        }
        //        result;
        //        """
        //
        //        webView.evaluateJavaScript(js) { (result, error) in
        //            if let elements = result as? [[String: Any]] {
        //                print("@@@\n")
        //                for element in elements {
        //                    //                    if element["tag"] as? String != "INPUT" { continue }
        //                    print("@@@ Tag: \(element["tag"] ?? ""), ID: \(element["id"] ?? "none"), Class: \(element["class"] ?? "none")")
        //                }
        //            } else if let error = error {
        //                print("@@@ JavaScript error: \(error.localizedDescription)")
        //            }
        //        }
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
        if let url = URL(string: Constants.mjcUrl) {
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
    
    private func addPartialIdScript() {
        let partialIdScript = """
        var observer = new MutationObserver(function(mutations) {
            // Поиск всех элементов с атрибутом id
            var elements = document.querySelectorAll('[id]');
            
            elements.forEach(element => {
                if (element.id.includes('\(Constants.inputpartitialID)') && element.tagName == '\(Constants.inputTagName)') {
                    window.webkit.messageHandlers.partialIdHandler.postMessage({
                        found: true,
                        fullId: element.id,
                        tagName: element.tagName,
                        html: element.outerHTML
                    });
                }
            });
        });
        
        observer.observe(document, {
            childList: true,
            subtree: true,
            attributeFilter: ['id']
        });
        """
        
        let script = WKUserScript(source: partialIdScript,
                                  injectionTime: .atDocumentEnd,
                                  forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(script)
        webView.configuration.userContentController.add(self, name: "partialIdHandler")
    }
    
    private func addLoadCompleteScript() {
        let loadCompleteScript = """
        // Проверяем статус загрузки документа
        if (document.readyState === 'complete') {
            // Проверяем загрузку изображений
            const images = Array.from(document.images);
            const loadedImages = images.filter(img => img.complete);
            
            // Проверяем загрузку iframe
            const iframes = Array.from(document.getElementsByTagName('iframe'));
            const loadedIframes = iframes.filter(iframe => iframe.contentDocument?.readyState === 'complete');
            
            window.webkit.messageHandlers.pageLoadHandler.postMessage({
                documentReady: true,
                allImagesLoaded: images.length === loadedImages.length,
                allIframesLoaded: iframes.length === loadedIframes.length,
                totalElements: document.getElementsByTagName('*').length
            });
        } else {
            window.addEventListener('load', function() {
                // Повторная проверка после события load
                const checkInterval = setInterval(() => {
                    const images = Array.from(document.images);
                    if (images.every(img => img.complete)) {
                        clearInterval(checkInterval);
                        window.webkit.messageHandlers.pageLoadHandler.postMessage({
                            documentReady: true,
                            allImagesLoaded: true,
                            allIframesLoaded: Array.from(document.getElementsByTagName('iframe'))
                                .every(iframe => iframe.contentDocument?.readyState === 'complete'),
                            totalElements: document.getElementsByTagName('*').length
                        });
                    }
                }, 100);
            });
        }
        """
        
        let script = WKUserScript(source: loadCompleteScript,
                                  injectionTime: .atDocumentEnd,
                                  forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(script)
        webView.configuration.userContentController.add(self, name: "pageLoadHandler")
    }
}

extension MainViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.loadingFinished = false
        print("@@@ началась загрузка страницы:", webView.title ?? "")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.loadingFinished = true
        self.currentLoadedPageName = webView.title ?? ""
        print("@@@ завершена загрузка страницы:", webView.title ?? "")
    }
    
    // Обрабатываем ошибки загрузки
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("@@@ Ошибка загрузки: \(error.localizedDescription)")
    }
}

extension MainViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        switch message.name {
        case "partialIdHandler":
            if self.loadingFinished { //,
                //               let data = message.body as? [String: Any] {
                widgetLoaded = true
                //                print("@@@", data["tagName"] ?? "", data["fullId"] ?? "")
            }
            
        case "pageLoadHandler":
            if self.loadingFinished,
               let data = message.body as? [String: Any] {
                //                print("@@@ Статус загрузки страницы: \(data)")
                
                if let complete = data["allImagesLoaded"] as? Bool, complete {
                    if data["totalElements"] as? Int ?? 0 == 13 {
                        elementsLoaded = true
                    }
                    //                    print("@@@ Все элементы страницы загружены", data["totalElements"] ?? 0)
                    // Действия после загрузки
                }
            }
            
        default:
            break
        }
    }
}

extension MainViewController: ClickTrackingWebViewDelegate {
    func clickTracked(on point: CGPoint) {
        loadingFinished = false
        print("@@@ CLICK", point)
    }
}
