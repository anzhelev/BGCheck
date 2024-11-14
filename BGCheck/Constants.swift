//
//  Constants.swift
//  BGCheck
//
//  Created by Andrey Zhelev on 14.11.2024.
//
import Foundation

enum Constants {
    static let url = "https://publicbg.mjs.bg/BgInfo"
    static let numberInputJavaScript = "document.getElementById('reqNun').value = '\(UserDefaults.standard.string(forKey: "storedNumber") ?? "")';"
    static let pinInputJavaScript = "document.getElementById('pin').value = '\(UserDefaults.standard.string(forKey: "storedPin") ?? "")';"
    static let clickOnButtonJavaScript = "document.getElementsByTagName('button')[0].click();"
}
