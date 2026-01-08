import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private var alertPresenter = AlertPresenter()
    
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        imageView.layer.cornerRadius = 20
        
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // приватный метод, который меняет цвет рамки
    // принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
        
        let color: CGColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        if isCorrect == true {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = color
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.showNextQuestionOrResults()
        }
        
    }
    
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
      
        let quizStepViewModelResult = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        return quizStepViewModelResult
        
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // приватный метод для показа результатов раунда квиза
    // принимает вью модель QuizResultsViewModel и ничего не возвращает
    private func show(quiz result: QuizResultsViewModel) {
        
        let alertModel = AlertModel(
                title: result.title,
                message: result.text,
                buttonText: result.buttonText,
                accessibilityIdentifier: "Game results") { [weak self] in
                    
                    guard let self else { return }
                    
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion()
                    
                }
        
        alertPresenter.presentAlert(viewController: self, alertModel: alertModel)

    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
      if currentQuestionIndex == questionsAmount - 1 { // 1
          
          // сохраняем результат
          statisticService.store(gameResult: GameResult(correct: correctAnswers, total: questionsAmount, date: Date()))
          
          let gamesCount = statisticService.gamesCount
          let bestGameCorrect = statisticService.bestGame.correct
          let bestGameTotal = statisticService.bestGame.total
          let bestGameDate = statisticService.bestGame.date
          let totalAccuracy = statisticService.totalAccuracy
          
          // идём в состояние "Результат квиза"
          let viewModel = QuizResultsViewModel(
            title: "Этот раунд окончен!",
            text: "Ваш результат: \(correctAnswers)/\(questionsAmount)\n"
                    + "Количество сыгранных квизов: \(gamesCount)\n"
                    + "Рекорд: \(bestGameCorrect)/\(bestGameTotal) (\(bestGameDate.dateTimeString))\n"
                    + "Средняя точность: \(String(format: "%.2f", totalAccuracy))%",
            buttonText: "Сыграть ещё раз")
          
          show(quiz: viewModel)
            
      } else { // 2
          currentQuestionIndex += 1
          // идём в состояние "Вопрос показан"
          
          questionFactory?.requestNextQuestion()
      }
        
        imageView.layer.borderWidth = 0 // толщина рамки
        
        enabledButtons(true)
        
    }
    
    private func enabledButtons(_ isEnabled: Bool) {
        yesButton.isUserInteractionEnabled = isEnabled
        noButton.isUserInteractionEnabled = isEnabled
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false      // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating()      // включаем анимацию
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true       // говорим, что индикатор загрузки скрыт
        activityIndicator.stopAnimating()       // выключаем анимацию
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        let alertModel = AlertModel(
                title: "Ошибка",
                message: message,
                buttonText: "Попробовать ещё раз?") { [weak self] in
                    
                    guard let self else { return }
                    
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    self.questionFactory?.loadData()
                    
                }
        
        alertPresenter.presentAlert(viewController: self, alertModel: alertModel)
    }
    
    func didLoadDataFromServer() {
        
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()

    }

    func didFailToLoadData(with error: Error) {
        
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки

    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        
        enabledButtons(false)
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
        
    }

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        
        enabledButtons(false)
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
        
    }

}
