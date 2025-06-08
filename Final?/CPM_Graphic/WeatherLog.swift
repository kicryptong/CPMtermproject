//
//  WeatherLog.swift
//  NewWeather
//
//  Created by 성준영 on 5/28/25.
//
//

import Foundation

struct WeatherLog: Identifiable, Codable, Hashable { // Hashable 추가 (List에서 사용 편의성)
    let id: UUID
    let timestamp: Date
    let location: String
    let temperature: String
    let description: String
    let mainWeather: String // 예: "Clear", "Rain"
    let windSpeed: Double
    var userMemo: String?

    // 초기화 편의를 위해 기본값 제공
    init(id: UUID = UUID(),
         timestamp: Date = Date(),
         location: String,
         temperature: String,
         description: String,
         mainWeather: String,
         windSpeed: Double,
         userMemo: String? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.location = location
        self.temperature = temperature
        self.description = description
        self.mainWeather = mainWeather
        self.windSpeed = windSpeed
        self.userMemo = userMemo
    }

    // 날짜 포맷팅을 위한 computed property
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: timestamp)
    }
}
