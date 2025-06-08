//
//  WeatherLogManager.swift
//  NewWeather
//
//  Created by 성준영 on 5/28/25.
//


import Foundation
import Combine

class WeatherLogManager: ObservableObject {
    @Published var savedLogs: [WeatherLog] = []

    private let userDefaultsKey = "weatherLogs"

    init() {
        loadLogs()
    }

    func addLog(weather: Weather, locationName: String, memo: String? = nil) {
        let newLog = WeatherLog(
            location: locationName,
            temperature: weather.temperature + "°C",
            description: weather.description,
            mainWeather: weather.main,
            windSpeed: weather.windSpeed, // Weather 구조체에 windSpeed가 있다고 가정
            userMemo: memo
        )
        savedLogs.insert(newLog, at: 0) // 최신 로그를 맨 위에 추가
        saveLogs()
    }

    func deleteLog(at offsets: IndexSet) {
        savedLogs.remove(atOffsets: offsets)
        saveLogs()
    }
    
    func deleteLog(log: WeatherLog) {
        if let index = savedLogs.firstIndex(where: { $0.id == log.id }) {
            savedLogs.remove(at: index)
            saveLogs()
        }
    }

    private func saveLogs() {
        if let encodedData = try? JSONEncoder().encode(savedLogs) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        }
    }

    private func loadLogs() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey) {
            if let decodedLogs = try? JSONDecoder().decode([WeatherLog].self, from: savedData) {
                savedLogs = decodedLogs
                return
            }
        }
        savedLogs = []
    }
}
