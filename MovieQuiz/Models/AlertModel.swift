//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Артем Кохан on 11.10.2022.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
