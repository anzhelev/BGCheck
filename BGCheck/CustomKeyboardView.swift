//
//  CustomKeyboardView.swift
//  BGCheck
//
//  Created by Andrey Zhelev on 31.07.2024.
//
import UIKit

class CustomKeyboardView: UIInputView {
    // Implement your custom keyboard UI here
    
    override init(frame: CGRect, inputViewStyle: UIInputView.Style) {
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        
        let button = UIButton(type: .system)
        button.setTitle("Insert", for: .normal)
        button.addTarget(self, action: #selector(insertText), for: .touchUpInside)
        
        // Add the button to your custom keyboard UI
        addSubview(button)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func insertText() {
        // Handle the text insertion logic here
        // Access the text input view and insert the desired text
        
//        if let textInput = self.textInputDelegate as? UITextInput {
//            textInput.insertText("Custom Text")
//        }
    }
}
