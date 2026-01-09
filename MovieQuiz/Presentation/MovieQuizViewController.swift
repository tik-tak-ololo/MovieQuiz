import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    private var presenter: MovieQuizPresenter!
    private var alertPresenter = AlertPresenter()
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        
        imageView.layer.cornerRadius = 20
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // приватный метод для показа результатов раунда квиза
    // принимает вью модель QuizResultsViewModel и ничего не возвращает
    func show(quiz result: QuizResultsViewModel) {
        
        let alertModel = AlertModel(
                title: result.title,
                message: result.text,
                buttonText: result.buttonText,
                accessibilityIdentifier: "Game results") { [weak self] in
                    guard let self else { return }
                    self.presenter.restartGame()
                }
        
        alertPresenter.presentAlert(viewController: self, alertModel: alertModel)
    }
        
    func enabledButtons(_ isEnabled: Bool) {
        yesButton.isUserInteractionEnabled = isEnabled
        noButton.isUserInteractionEnabled = isEnabled
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false      // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating()      // включаем анимацию
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true       // говорим, что индикатор загрузки скрыт
        activityIndicator.stopAnimating()       // выключаем анимацию
    }

    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        let alertModel = AlertModel(
                title: "Ошибка",
                message: message,
                buttonText: "Попробовать ещё раз?") { [weak self] in
                    guard let self else { return }
                    self.presenter.restartGame()
                }
        
        alertPresenter.presentAlert(viewController: self, alertModel: alertModel)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }

}
