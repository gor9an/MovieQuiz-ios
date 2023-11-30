import UIKit

final class MovieQuizViewController: UIViewController,
                                     AlertPresenterDelegate,
                                     StatisticServiceDelegate {
    
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var alertPresenter: AlertPresenterProtocol = AlertPresenter()

    var statisticService: StatisticService = StatisticServiceImplementation()
    private var accuracy: Double = 0.0
    
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        
        noButton.layer.cornerRadius = 15
        yesButton.layer.cornerRadius = 15
        imageView.layer.cornerRadius = 20
        
        activityIndicator.hidesWhenStopped = true
        
        presenter.restartGame()
        
        showLoadingIndicator()
        
        alertPresenter.delegate = self
        statisticService.delegate = self
        
        accuracy = UserDefaults.standard.double(forKey: "total")
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
        
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.presenter.statisticService = self.statisticService
            
            self.presenter.showNextQuestionOrResults()
            
            self.imageView.layer.borderWidth = 0 // толщина рамки
            
            self.noButton.isEnabled = true
            self.yesButton.isEnabled = true

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
    
    func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        let errorAlert = AlertModel(
            title: "Ошибка",
            message: "Данные из сети не загружены",
            buttonText: "Попробовать ещё раз")
        alertPresenter.requestAlert(quiz: errorAlert)
        
        self.presenter.restartGame()
    }
    
    // MARK: - AlertPresenterDelegate
    func didReceiveAlert() {
        presenter.restartGame()
        presenter.questionFactory!.requestNextQuestion()
    }
    
    // MARK: - StatisticServiceDelegate
    func didReceiveStatistic() -> Double {
        accuracy += Double(presenter.correctAnswers)/Double(presenter.questionsAmount) * 100
        UserDefaults.standard.set(accuracy, forKey: "total")
        
        return UserDefaults.standard.double(forKey: "total") / Double(statisticService.gamesCount)
    }
}
