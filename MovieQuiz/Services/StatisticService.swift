//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Артем Кохан on 14.10.2022.
//


import Foundation

struct GameRecord: Codable, Comparable {
    let correct: Int //Количество правильных ответов
    let total: Int //Количество вопросов квиза
    let date: Date //Дата завершения раунда
    
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        
        //Решил сравнивать через процент чтоб если мы захотим изменить количество вопросов то статистика осталась релевантной
        let lhsPercent = lhs.total == 0 ? 0.0 : Double(lhs.correct) / Double(lhs.total)
        let rhsPercent = rhs.total == 0 ? 0.0 : Double(rhs.correct) / Double(rhs.total)
        
        return lhsPercent < rhsPercent
    }
}

struct Top: Codable {
    let totalAccuracy: Double
    let gamesCount: Int
    let bestGame: GameRecord
}

protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    
    var totalAccuracy: Double { get } // Отображает среднюю точность правильных ответов за все игры в процентах.
    var gamesCount: Int { get } // Количество завершённых игр.
    var bestGame: GameRecord { get } //Информация о лучшей попытке.
    
    var currentGame: GameRecord { get set }
}

final class StatisticServiceImplementation: StatisticService {
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    enum FileManagerError: Error {
        case fileDoesntExist
    }
   
    let statisticsFileName = "Statistics.json"
    var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    var currentGame: GameRecord
    
    private let userDefaults = UserDefaults.standard
    
    private(set) var totalAccuracy: Double {
        get {
            guard let data = userDefaults.data(forKey: Keys.total.rawValue),
                  let record = try? JSONDecoder().decode(Double.self, from: data) else {
                return 0
            }
            
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.total.rawValue)
        }
    }
    
    private(set) var gamesCount: Int  {
        get {
            guard let data = userDefaults.data(forKey: Keys.gamesCount.rawValue),
                  let record = try? JSONDecoder().decode(Int.self, from: data) else {
                return 0
            }
            
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    private(set) var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func string(from documentsURL: URL) throws -> String {
        if !FileManager.default.fileExists(atPath: documentsURL.path) {
            throw FileManagerError.fileDoesntExist
            }
            return try String(contentsOf: documentsURL)
    }
    
    
    func store(correct count: Int, total amount: Int) {
    
        totalAccuracy = (totalAccuracy * Double(gamesCount) + Double(count)/Double(amount)) / Double(gamesCount+1)
        gamesCount += 1
        currentGame = GameRecord(correct: count, total: amount, date: Date())
    
        if bestGame<currentGame {
            bestGame = currentGame
        }
        
        guard let documentsURL = documentsURL else {
            return
        }
        
        let top = Top(totalAccuracy: totalAccuracy, gamesCount: gamesCount, bestGame: bestGame)
        
        do {
            let topData = try JSONEncoder().encode(top)
            FileManager.default.createFile(atPath: documentsURL.path, contents: topData)
        } catch {
            print("Не смогли сериализовать")
        }
        
    }
    init() {
        
        currentGame = GameRecord(correct: 0, total: 0, date: Date())
        bestGame = GameRecord(correct: 0, total: 0, date: Date())
        gamesCount = 0
        totalAccuracy = 0
        
        guard var documentsURL = documentsURL else {
            return
        }
        
        documentsURL.appendPathComponent(statisticsFileName)
        
        var jsonString = ""
        
        do {
            jsonString = try string(from: documentsURL)
        } catch FileManagerError.fileDoesntExist {
            print("Файл по адресу \(documentsURL.path) не существует")
        } catch {
            print("Неизвестная ошибка чтения из файла \(error)")
        }
        
        let data = jsonString.data(using: .utf8)!
        let result = try? JSONDecoder().decode(Top.self, from: data)
        
        bestGame = result?.bestGame ?? GameRecord(correct: 0, total: 0, date: Date())
        gamesCount = result?.gamesCount ?? 0
        totalAccuracy = result?.totalAccuracy ?? 0

    }
}
