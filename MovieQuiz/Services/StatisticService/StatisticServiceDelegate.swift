//
//  StatisticServiceDelegate.swift
//  MovieQuiz
//
//  Created by Andrey Gordienko on 10.11.2023.
//

import Foundation

protocol StatisticServiceDelegate: AnyObject {
    func didReceiveStatistic() -> Double
}
