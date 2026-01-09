//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Сергей Хмелёв on 09.01.2026.
//

import UIKit

final class MovieQuizPresenter {
    
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    func convert(model: QuizQuestion) -> QuizStepViewModel {
      
        let quizStepViewModelResult = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        return quizStepViewModelResult
        
    }
    
    func yesButtonClicked() {
        
        viewController?.enabledButtons(false)
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer)
        
    }
    
    func noButtonClicked() {
        
        viewController?.enabledButtons(false)
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        viewController?.showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
        
    }
    
}
