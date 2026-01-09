//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Сергей Хмелёв on 10.01.2026.
//

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    
    func enabledButtons(_ isEnabled: Bool)
}
