//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Сергей Хмелёв on 07.12.2025.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let accessibilityIdentifier: String
    let closure: () -> Void
    
    
    init(title: String, message: String, buttonText: String, closure: @escaping () -> Void) {
        self.title = title
        self.message = message
        self.buttonText = buttonText
        self.accessibilityIdentifier = ""
        self.closure = closure
    }
    
    init(title: String, message: String, buttonText: String, accessibilityIdentifier: String, closure: @escaping () -> Void) {
        self.title = title
        self.message = message
        self.buttonText = buttonText
        self.accessibilityIdentifier = accessibilityIdentifier
        self.closure = closure
    }
    
}
