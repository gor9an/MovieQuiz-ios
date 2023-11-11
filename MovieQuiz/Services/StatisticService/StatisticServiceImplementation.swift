//
//  StatisticServiceImplementation.swift
//  MovieQuiz
//
//  Created by Andrey Gordienko on 08.11.2023.
//

import Foundation

final class StatisticServiceImplementation: StatisticService {
    var delegate: StatisticServiceDelegate?
    
    private let userDefaults = UserDefaults.standard
    var totalAccuracy: Double {
        get { 
            return delegate?.didReceiveStatistic() ?? 0.0
        }
    }
    var gamesCount: Int {
        get { 
            guard let data = userDefaults.data(forKey: Keys.gamesCount.rawValue),
                let count = try? JSONDecoder().decode(Int.self, from: data) else {
                return 0
            }
            
            return count
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
            print("Невозможно сохранить количество игр")
            return
        }
        
        userDefaults.set(data, forKey: Keys.gamesCount.rawValue) }
    }
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            
            return record
        }

        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    func store(correct count: Int, total amount: Int) {
        if count > amount {
            bestGame = .init(correct: count, total: gamesCount, date: Date())
        }
        gamesCount += 1
    }
}
