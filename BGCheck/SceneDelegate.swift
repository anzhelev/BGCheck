import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Public Properties
    var window: UIWindow?

    // MARK: - Lifecycle
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = setRootVC()
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        NotificationService.shared.synchronizeNotifications { success, error in
            if !success {
                print("@@@ Error synchronizing notifications: \(String(describing: error))")
            }
        }
    }

    // MARK: - Public Methods
    func setRootVC() -> UIViewController {
        let shouldSkipOnboarding = UserDefaults.standard.bool(forKey: "storedCases")

        return shouldSkipOnboarding
            ? WebViewVC()
            : UINavigationController(rootViewController: OnboardingVC())
    }
}
