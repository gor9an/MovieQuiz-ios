//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//
//  Created by Andrey Gordienko on 30.11.2023.
//

import XCTest
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

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
} 
