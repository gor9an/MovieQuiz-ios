import UIKit

final class MovieQuizViewController: UIViewController,
                                     QuestionFactoryDelegate,
                                     AlertPresenterDelegate,
                                     StatisticServiceDelegate {
    
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol = AlertPresenter()

    private var statisticService: StatisticService = StatisticServiceImplementation()
    private var accuracy: Double = UserDefaults.standard.double(forKey: "total")
    
    private let presenter = MovieQuizPresenter()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        noButton.layer.cornerRadius = 15
        yesButton.layer.cornerRadius = 15
        imageView.layer.cornerRadius = 20
        
        activityIndicator.hidesWhenStopped = true
        
        showLoadingIndicator()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
        
        
        questionFactory?.loadData()
        
        questionFactory?.delegate = self
        alertPresenter.delegate = self
        questionFactory?.requestNextQuestion()
        statisticService.delegate = self
        
        presenter.viewController = self
    }
    
    // MARK: - Actions
    // метод вызывается, когда пользователь нажимает на кнопку "Нет"
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - Private functions
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.imageView.layer.borderWidth = 0 // толщина рамки
            
            self.noButton.isEnabled = true
            self.yesButton.isEnabled = true
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: statisticService.bestGame.correct)
            
            let text = """
Вы ответили на \(correctAnswers) из \(presenter.questionsAmount)\n
Количество игр: \(statisticService.gamesCount)\n
Рекорд: \(statisticService.bestGame.correct) (\(statisticService.bestGame.date.dateTimeString))\n
Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
"""
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть еще раз")
            
            alertPresenter.requestAlert(quiz: viewModel)
            
        } else { // 2
            presenter.switchToNextQuestion()
            
            self.questionFactory!.requestNextQuestion()
        }
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        let errorAlert = AlertModel(
            title: "Ошибка",
            message: "Данные из сети не загружены",
            buttonText: "Попробовать ещё раз")
        alertPresenter.requestAlert(quiz: errorAlert)
        
        self.presenter.resetQuestionIndex()
        self.correctAnswers = 0
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator() // скрываем индикатор загрузки
        questionFactory!.requestNextQuestion()
    }
    
    // MARK: - AlertPresenterDelegate
    func didReceiveAlert() {
        presenter.resetQuestionIndex()
        questionFactory!.requestNextQuestion()
    }
    
    // MARK: - StatisticServiceDelegate
    func didReceiveStatistic() -> Double {
        accuracy += Double(correctAnswers)/Double(presenter.questionsAmount) * 100
        UserDefaults.standard.set(accuracy, forKey: "total")
        
        return UserDefaults.standard.double(forKey: "total") / Double(statisticService.gamesCount)
    }
}
