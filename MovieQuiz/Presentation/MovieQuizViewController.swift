import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(delegate: self)
        
        questionFactory?.requestNextQuestion()
        
        }
    
    // MARK: - QuestionFactoryDelegate
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
                    return
                }
                
                currentQuestion = question
                let viewModel = convert(model: question)
                DispatchQueue.main.async { [weak self] in
                    self?.show(quiz: viewModel)
                }
    }
    
    // MARK: - AlertPresenterDelegate
    func didShowAlert(alert: UIAlertController?) {
        guard let alert = alert else {
                    return
                }
                
                DispatchQueue.main.async { [weak self] in
                    self?.present(alert, animated: true, completion: nil)
                }
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
    }
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    
    @IBOutlet weak private var noUIButton: UIButton!
    
    @IBOutlet weak private var yesUIButton: UIButton!
   
    private var correctAnswers: Int = 0
    private var currentQuestionIndex: Int = 0
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
//    private var currentGame: GameRecord
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        turnOnButtons()
    }

    private func show(quiz result: QuizResultsViewModel) {

        guard let statisticService = statisticService else { return }
        
        let alertModel = AlertModel(
            title: result.title,
            message: """
                Ваш результат: \(statisticService.currentGame.correct)/\(statisticService.currentGame.total)\n
                Количество сыгранных квизов: \(statisticService.gamesCount)\n
                Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))\n
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                """,
            buttonText: result.buttonText,
            completion: {[weak self] in
                            guard let self = self else { return }
                
                            self.currentQuestionIndex = 0
                
                            self.correctAnswers = 0
                
                            self.questionFactory?.requestNextQuestion()
                        }
        )
        alertPresenter = AlertPresenter(alertModel: alertModel)
        alertPresenter?.viewController = self
        
        alertPresenter?.requestAlert()
    }

    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        turnOffButtons()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            self.showNextQuestionOrResults()
        }
    }
    
    private func turnOnButtons() {
        yesUIButton.isEnabled = true
        noUIButton.isEnabled = true
    }
    
    private func turnOffButtons() {
        yesUIButton.isEnabled = false
        noUIButton.isEnabled = false
    }

    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }

    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            
            let text = correctAnswers == questionsAmount ?
                    "Поздравляем, Вы ответили на 10 из 10!" :
                    "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
}





