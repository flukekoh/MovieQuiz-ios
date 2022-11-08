import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statisticService = StatisticServiceImplementation()
        
        showLoadingIndicator()
        
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    
    @IBOutlet weak private var noUIButton: UIButton!
    
    @IBOutlet weak private var yesUIButton: UIButton!
    
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
        
        textLabel.text = ""
        counterLabel.text = ""
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true // говорим, что индикатор загрузки скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        // создайте и покажите алерт
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] in
                guard let self = self else { return }
                
                self.showLoadingIndicator()
                self.presenter.restartGame()
                            
            }
        )
        alertPresenter = AlertPresenter(alertModel: alertModel)
        alertPresenter?.viewController = self
        
        alertPresenter?.requestAlert()
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        turnOnButtons()
    }
    
    func show(quiz result: QuizResultsViewModel) {
        
        guard let statisticService = statisticService else { return }
        
        let alertModel = AlertModel(
            title: result.title,
            message: """
                Ваш результат: \(statisticService.currentGame.correct)/\(statisticService.currentGame.total)\n
                Количество сыгранных квизов: \(statisticService.gamesCount)\n
                Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))\n
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy*100))%
                """,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self = self else { return }
                
                self.presenter.restartGame()
            }
        )
        alertPresenter = AlertPresenter(alertModel: alertModel)
        alertPresenter?.viewController = self
        
        alertPresenter?.requestAlert()
    }
    
    func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        turnOffButtons()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {
                return
            }
            self.presenter.statisticService = self.statisticService
            self.presenter.showNextQuestionOrResults()
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
    
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            
            statisticService?.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
            
            let text = presenter.correctAnswers == presenter.questionsAmount ?
            "Поздравляем, Вы ответили на 10 из 10!" :
            "Вы ответили на \(presenter.correctAnswers) из 10, попробуйте ещё раз!"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            presenter.switchToNextQuestion()
        }
    }
}





