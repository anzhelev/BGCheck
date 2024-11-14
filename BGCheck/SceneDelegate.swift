//
//  SceneDelegate.swift
//  BGCheck
//
//  Created by Andrey Zhelev on 30.07.2024.
//
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = setRootVC()
        self.window = window
        window.makeKeyAndVisible()
    }
    
    func setRootVC() -> UIViewController {
        let shouldSkipOnboarding = !(UserDefaults.standard.string(forKey: "storedNumber") ?? "").isEmpty
        
        return shouldSkipOnboarding
        ? MainViewController()
        : OnboardingViewController()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        
    }
}

