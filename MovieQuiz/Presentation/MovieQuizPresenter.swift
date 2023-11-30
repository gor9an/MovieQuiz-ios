//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Andrey Gordienko on 30.11.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate,
                                StatisticServiceDelegate {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var correctAnswers = 0
    
    private var accuracy: Double = 0.0
    
    var statisticService: StatisticService!
    
    var currentQuestion: QuizQuestion?
    var questionFactory: QuestionFactoryProtocol?
    
    weak var viewController: MovieQuizViewController?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        statisticService.delegate = self
        
        accuracy = UserDefaults.standard.double(forKey: "total")
        
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
    
    func proceedWithAnswer(isCorrect: Bool) {
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        didAnswer(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
            
            self.viewController?.hideHighlightImageBorder()
        }
    }
    
    
    private func didAnswer(isYes: Bool) {
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
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
    
    
    func proceedToNextQuestionOrResults() {
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
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    // MARK: - StatisticServiceDelegate
    func didReceiveStatistic() -> Double {
        accuracy += Double(correctAnswers)/Double(questionsAmount) * 100
        UserDefaults.standard.set(accuracy, forKey: "total")
        
        return UserDefaults.standard.double(forKey: "total") / Double(statisticService.gamesCount)
    }
}
