//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Andrey Gordienko on 20.10.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {               
    func didReceiveNextQuestion(question: QuizQuestion?)
}
