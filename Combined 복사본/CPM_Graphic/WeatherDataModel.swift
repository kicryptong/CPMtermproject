import Foundation

// 풍속 정보를 위한 구조체
struct OpenWeatherWind: Decodable {
    let speed: Double // m/s
    let deg: Int?     // 풍향 (도)
    let gust: Double? // 돌풍 (m/s) - 필요시 사용
}

struct OpenWeatherResponse: Decodable {
    let name: String
    let main: OpenWeatherMain
    let weather: [OpenWeatherWeather]
    let wind: OpenWeatherWind // 풍속 정보 추가

    // JSON 키와 Swift 프로퍼티 이름이 다를 경우 CodingKeys 사용 (현재는 필요 없음)
}

struct OpenWeatherMain: Decodable {
    let temp: Double
    let feels_like: Double?
    let temp_min: Double?
    let temp_max: Double?
    let pressure: Int?
    let humidity: Int?
}

struct OpenWeatherWeather: Decodable {
    let id: Int?
    let description: String
    let main: String // 예: "Clear", "Clouds", "Rain"
    let icon: String?
}

public struct Weather {
    let location: String
    let temperature: String // "°C" 제외한 숫자 문자열로 변경 (활용성 증대)
    let description: String
    let main: String
    let windSpeed: Double // 풍속 추가 (m/s)
    let iconName: String? // 아이콘 코드

    init(response: OpenWeatherResponse) {
        location = response.name
        temperature = "\(Int(response.main.temp.rounded()))" // 정수로 반올림하여 문자열로
        description = response.weather.first?.description.capitalized ?? "정보 없음" // 첫 글자 대문자로
        main = response.weather.first?.main ?? "정보 없음"
        windSpeed = response.wind.speed
        iconName = response.weather.first?.icon
    }
}
