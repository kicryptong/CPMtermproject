// ForecastWeatherModel.swift

import Foundation

// <<<< 풍속 정보를 담을 WindInfo 구조체 새로 추가 >>>>
struct WindInfo: Codable {
    let speed: Double // 풍속 (m/s)
    let deg: Int?     // 풍향 (도) - 참고용, 현재 판단 기준에는 미사용
    let gust: Double? // 돌풍 (m/s) - 참고용, 현재 판단 기준에는 미사용
}

struct ForecastWeatherResponse: Codable {
    let list: [ForecastItem]
}

struct ForecastItem: Codable, Identifiable {
    let id = UUID() // 이 부분에 대한 경고는 있었지만, 현재 기능에는 영향 없음
    let dt: TimeInterval
    let main: TemperatureInfo
    let weather: [WeatherInfo]
    let wind: WindInfo // <<<< wind 속성 추가 >>>>

    var date: Date {
        return Date(timeIntervalSince1970: dt)
    }

    struct TemperatureInfo: Codable {
        let temp: Double
    }

    struct WeatherInfo: Codable {
        let main: String        // 예: "Clear", "Clouds", "Rain" (판단 기준에 사용)
        let description: String // 예: "맑음", "구름 많음" (표시용)
        // let icon: String?    // 아이콘 표시 등에 사용 가능
    }
}
