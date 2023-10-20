//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Andrey Gordienko on 20.10.2023.
//

import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion() -> QuizQuestion?
}
