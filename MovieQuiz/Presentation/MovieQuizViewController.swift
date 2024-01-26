import UIKit

final class MovieQuizViewController: UIViewController,
                                     MovieQuizViewControllerProtocol,
                                     AlertPresenterDelegate {
    
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var alertPresenter: AlertPresenterProtocol = AlertPresenter()
    
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
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    func hideHighlightImageBorder() {
        imageView.layer.borderWidth = 0 // толщина рамки
        noButton.isEnabled = true
        yesButton.isEnabled = true
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
}
