//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Сергей Хмелёв on 06.12.2025.
//

import Foundation

struct QuizQuestion {

    // картинка
    let image: Data
    
    // строка с вопросом о рейтинге фильма
    let text: String
    
    // булевое значение (true, false), правильный ответ на вопрос
    let correctAnswer: Bool
}
