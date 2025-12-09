//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Сергей Хмелёв on 07.12.2025.
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    var gamesCount: Int {
        
        get {
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            
            let bestGameCorrect: Int = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let bestGameTotal: Int = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let bestGameDate: Date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            
            return GameResult(correct: bestGameCorrect, total: bestGameTotal, date: bestGameDate)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        
        get {
            return totalQuestionsAsked == 0 ? 0.0 : Double(totalCorrectAnswers) / Double(totalQuestionsAsked) * 100.0
        }
        
    }
    
    private var totalCorrectAnswers: Int {
        
        get {
            return storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        
        set {
            storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
        
    }
    
    private var totalQuestionsAsked: Int {
        
        get {
            return storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
        }
        
        set {
            storage.set(newValue, forKey: Keys.totalQuestionsAsked.rawValue)
        }
        
    }
    
    private let storage: UserDefaults = .standard
    
    func store(gameResult: GameResult) {
        
        gamesCount += 1
        
        totalQuestionsAsked += gameResult.total
        totalCorrectAnswers += gameResult.correct
        
        if gameResult.correct > bestGame.correct {
            bestGame = gameResult
        }
        
    }
    
}

private enum Keys: String {
    case gamesCount          // Для счётчика сыгранных игр
    case bestGameCorrect     // Для количества правильных ответов в лучшей игре
    case bestGameTotal       // Для общего количества вопросов в лучшей игре
    case bestGameDate        // Для даты лучшей игры
    case totalCorrectAnswers // Для общего количества правильных ответов за все игры
    case totalQuestionsAsked // Для общего количества вопросов, заданных за все игры
}
