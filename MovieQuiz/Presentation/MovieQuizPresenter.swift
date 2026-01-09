//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Сергей Хмелёв on 09.01.2026.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticServiceProtocol!
    private var currentQuestionIndex = 0
    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10
    private var correctAnswers: Int = 0
    
    init(viewController: MovieQuizViewControllerProtocol){
        self.viewController = viewController
        statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func yesButtonClicked() {
        
        viewController?.enabledButtons(false)
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        
        viewController?.enabledButtons(false)
        didAnswer(isYes: false)
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
      
        let quizStepViewModelResult = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        return quizStepViewModelResult
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func makeResultsMessage() -> String {
        
        let gamesCount = statisticService.gamesCount
        let bestGameCorrect = statisticService.bestGame.correct
        let bestGameTotal = statisticService.bestGame.total
        let bestGameDate = statisticService.bestGame.date
        let totalAccuracy = statisticService.totalAccuracy
        
        let resultMessage: String = "Ваш результат: \(correctAnswers)/\(self.questionsAmount)\n"
        + "Количество сыгранных квизов: \(gamesCount)\n"
        + "Рекорд: \(bestGameCorrect)/\(bestGameTotal) (\(bestGameDate.dateTimeString))\n"
        + "Средняя точность: \(String(format: "%.2f", totalAccuracy))%"
        
        return resultMessage
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer == true {
            correctAnswers += 1
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.showNextQuestionOrResults()
        }
        
    }
    
    private func showNextQuestionOrResults() {
        
        if self.isLastQuestion() {
            statisticService.store(gameResult: GameResult(correct: correctAnswers, total: self.questionsAmount, date: Date()))
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: makeResultsMessage(),
                buttonText: "Сыграть ещё раз")
              
            viewController?.show(quiz: viewModel)
            
          } else {
              currentQuestionIndex += 1
              questionFactory?.requestNextQuestion()
          }
        
        viewController?.enabledButtons(true)
    }
}
