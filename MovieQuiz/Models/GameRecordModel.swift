//
//  GameRecordModel.swift
//  MovieQuiz
//
//  Created by Andrey Gordienko on 08.11.2023.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ another: GameRecord) -> Bool {
        correct > another.correct
    }
}
