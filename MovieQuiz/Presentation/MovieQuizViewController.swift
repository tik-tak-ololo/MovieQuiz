import UIKit

final class MovieQuizViewController: UIViewController {
    
    private var questions: [QuizQuestion] = [
            QuizQuestion(
                image: "The Godfather",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Dark Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Kill Bill",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Avengers",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Deadpool",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Green Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Old",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "The Ice Age Adventures of Buck Wild",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Tesla",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Vivarium",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false)
        ]
    
    private var currentQuestionIndex = 0
    
    private var correctAnswers = 0
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        
        questions.shuffle()
        
        show(quiz: convert(model: questions[currentQuestionIndex]))
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
        
    }
    
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
      
        let quizStepViewModelResult = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
        
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
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.questions.shuffle()
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
            
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true)
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
      if currentQuestionIndex == questions.count - 1 { // 1
          // идём в состояние "Результат квиза"
          
          let viewModel = QuizResultsViewModel(
            title: "Вы прошли квиз!",
            text: "Вы ответили правильно на \(correctAnswers) из \(questions.count) вопросов.",
            buttonText: "Сыграть ещё раз")
          
          show(quiz: viewModel)
            
      } else { // 2
          currentQuestionIndex += 1
          // идём в состояние "Вопрос показан"

          let nextQuestion = questions[currentQuestionIndex]
          let viewModel = convert(model: nextQuestion)
          
          show(quiz: viewModel)
      }
        
        imageView.layer.borderWidth = 0 // толщина рамки
        
        enabledButtons(true)
        
    }
    
    private func enabledButtons(_ isEnabled: Bool) {
        yesButton.isUserInteractionEnabled = isEnabled
        noButton.isUserInteractionEnabled = isEnabled
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        
        enabledButtons(false)
        
        showAnswerResult(isCorrect: !questions[currentQuestionIndex].correctAnswer)
        
    }

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        
        yesButton.isUserInteractionEnabled = false
        noButton.isUserInteractionEnabled = false
        
        showAnswerResult(isCorrect: questions[currentQuestionIndex].correctAnswer)
        
    }

}

private struct QuizQuestion {
    // строка с названием фильма,
    // совпадает с названием картинки афиши фильма в Assets
    let image: String
    
    // строка с вопросом о рейтинге фильма
    let text: String
    
    // булевое значение (true, false), правильный ответ на вопрос
    let correctAnswer: Bool
}

private struct QuizStepViewModel {
    // картинка с афишей фильма с типом UIImage
    let image: UIImage
    
    // вопрос о рейтинге квиза
    let question: String
    
    // строка с порядковым номером этого вопроса (ex. "1/10")
    let questionNumber: String
}

private struct QuizResultsViewModel {
    // строка с заголовком алерта
    let title: String
    
    // строка с текстом о количестве набранных очков
    let text: String
    
    // текст для кнопки алерта
    let buttonText: String
}
