//
//  MovieQuizViewControllerMock.swift
//  MovieQuizTests
//
//  Created by Andrey Gordienko on 01.12.2023.
//

import Foundation
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    var alertPresenter: MovieQuiz.AlertPresenterProtocol = MovieQuiz.AlertPresenter()
    
    func hideHighlightImageBorder() {
        
    }
    
    func show(quiz step: QuizStepViewModel) {
        
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        
    }
    
    func showLoadingIndicator() {
        
    }
    
    func hideLoadingIndicator() {
        
    }
    
    func showNetworkError(message: String) {
        
    }
}
