//
//  AlertPresenterProtocol.swift
//  MovieQuiz
//
//  Created by Andrey Gordienko on 21.10.2023.
//

import Foundation

protocol AlertPresenterProtocol {
    var delegate: AlertPresenterDelegate? { get set }
    func requestAlert(quiz result: AlertModel)
}
