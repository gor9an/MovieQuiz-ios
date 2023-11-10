//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Andrey Gordienko on 08.11.2023.
//

import Foundation

protocol StatisticService {
    var delegate: StatisticServiceDelegate? { get set }
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
}


