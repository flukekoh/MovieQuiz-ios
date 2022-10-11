//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Артем Кохан on 11.10.2022.
//

import Foundation

protocol QuestionFactoryDelegate: class {                   // 1
    func didRecieveNextQuestion(question: QuizQuestion?)   // 2
}
