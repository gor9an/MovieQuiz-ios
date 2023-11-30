//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Andrey Gordienko on 30.11.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var correctAnswers = 0
    var statisticService: StatisticService = StatisticServiceImplementation()
    
    var currentQuestion: QuizQuestion?
    var questionFactory: QuestionFactoryProtocol?
    
    weak var viewController: MovieQuizViewController?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        viewController?.noButton.isEnabled = false
        viewController?.yesButton.isEnabled = false
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            viewController?.imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
        } else {
            viewController?.imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        
        currentQuestion = question
        
        viewController?.showLoadingIndicator()
        
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.hideLoadingIndicator()
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: statisticService.bestGame.correct)
            
            let text = """
Вы ответили на \(correctAnswers) из \(self.questionsAmount)\n
Количество игр: \(statisticService.gamesCount)\n
Рекорд: \(statisticService.bestGame.correct) (\(statisticService.bestGame.date.dateTimeString))\n
Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
"""
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть еще раз")
            
            viewController?.alertPresenter.requestAlert(quiz: viewModel)
            
        } else { // 2
            self.switchToNextQuestion()
            
            questionFactory?.requestNextQuestion()
        }
    }
    
    // MARK: - QuestionFactoryDelegate
}
