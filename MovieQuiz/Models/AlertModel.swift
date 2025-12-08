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
    let closure: () -> Void
}
