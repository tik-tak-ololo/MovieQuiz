//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Сергей Хмелёв on 06.12.2025.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    
    /* Временно закоментировал, Mock потребуется в спринте №7
     private var questions: [QuizQuestion] = [
            QuizQuestion(
                image: "The Godfather",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Dark Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Kill Bill",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Avengers",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Deadpool",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Green Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Old",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "The Ice Age Adventures of Buck Wild",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Tesla",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Vivarium",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false)
        ]*/
    
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate){
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func requestNextQuestion() {
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
           
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let quizQuestionData = generateQuizQuestionData(realRating: rating)
            
            let text = quizQuestionData.text
            let correctAnswer = quizQuestionData.correctAnswer
            
            let question = QuizQuestion(image: imageData,
                                         text: text,
                                         correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    func loadData() {
        
        let handler: (Result<MostPopularMovies, Error>) -> Void = { [weak self] result in
            
            DispatchQueue.main.async {
                
                guard let self = self else { return }
                
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items                       // сохраняем фильм в нашу новую переменную
                    self.delegate?.didLoadDataFromServer()                      // сообщаем, что данные загрузились
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)               // сообщаем об ошибке нашему MovieQuizViewController
                }
            }
        }
        
        moviesLoader.loadMovies(handler: handler)
    }
    
    private func generateQuizQuestionData(realRating: Float) -> (text: String, correctAnswer: Bool) {
        
        var result = ("", false)
        
        let rangeOfRatings: ClosedRange<Int> = 1...10
        let rating: Float = Float(rangeOfRatings.randomElement()!)
        
        let rangeOfOperatorNumbers = 0...1
        let operatorNumber = rangeOfOperatorNumbers.randomElement()!
                
        switch operatorNumber {
            
            case 0: result = ("Рейтинг этого фильма больше чем \(Int(rating))?", realRating > rating)
            case 1: result = ("Рейтинг этого фильма меньше чем \(Int(rating))?", realRating < rating)
            default : result = ("Рейтинг этого фильма больше чем 7?", realRating > 7)
            
        }
        
        return result
    }
}
