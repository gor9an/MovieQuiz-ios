//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Andrey Gordienko on 30.11.2023.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    var alertPresenter: AlertPresenterProtocol { get set }
    
    func show(quiz step: QuizStepViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    func hideHighlightImageBorder()
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}
