//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Сергей Хмелёв on 07.12.2025.
//

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(gameResult: GameResult)
}
