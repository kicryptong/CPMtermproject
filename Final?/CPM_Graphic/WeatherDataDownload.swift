// WeatherDataDownload.swift

import Foundation
import CoreLocation

class WeatherDataDownload {
    
    private let API_KEY = "5100de82d81f62da14faa8c12caa2315" // !!!!! 여기에 실제 OpenWeatherMap API 키를 입력하세요 !!!!!

    func getWeather(location: CLLocationCoordinate2D) async throws -> OpenWeatherResponse {
        // API 요청 시 언어 설정을 'en'으로 변경하여 영어로 받습니다.
        let urlStringWithLang = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.latitude)&lon=\(location.longitude)&appid=\(API_KEY)&units=metric&lang=en"
        
        guard let urlString = urlStringWithLang.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            fatalError("URL string encoding failed")
        }

        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL: \(urlString)")
        }
        
        let urlRequest = URLRequest(url: url)
        
        print("Requesting Weather URL: \(url)")
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            fatalError("Invalid response type")
        }
        
        print("Response Status Code: \(httpResponse.statusCode)")

        guard httpResponse.statusCode == 200 else {
            if let responseBody = String(data: data, encoding: .utf8) {
                print("API Error Response Body: \(responseBody)")
            }
            fatalError("Error fetching weather data - Status Code: \(httpResponse.statusCode)")
        }
                
        do {
            let decodedData = try JSONDecoder().decode(OpenWeatherResponse.self, from: data)
            return decodedData
        } catch let decodingError {
            print("JSON Decoding Error: \(decodingError)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Failed to decode JSON: \(jsonString)")
            }
            throw decodingError
        }
    }
}
