//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Артем Кохан on 27.10.2022.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    private enum JSONError: Error {
        case unexpectedJSON
    }
    // MARK: - NetworkClient
    private let networkClient = NetworkClient()
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        // Если мы не смогли преобразовать строку в URL, то приложение упадёт с ошибкой
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_dj439tze") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            
            switch result {
            case .success(let mostPopularMoviesData):
                if let mostPopularMovies = try? JSONDecoder().decode(MostPopularMovies.self, from: mostPopularMoviesData) {
                    handler(.success(mostPopularMovies))
                } else {
                    handler(.failure(JSONError.unexpectedJSON))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}

