//
//  ViewModels.swift
//  MovieQuiz
//
//  Created by Andrey Gordienko on 12.10.2023.
//

import UIKit

struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
}

// для состояния "Результат квиза"
struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
}

// вью модель для состояния "Вопрос показан"
struct QuizStepViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
}
