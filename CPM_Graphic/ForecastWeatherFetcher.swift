// ForecastWeatherFetcher.swift

import Foundation

func fetchForecastWeather(lat: Double, lon: Double, completion: @escaping ([ForecastItem]) -> Void) {
    let apiKey = "f5e18905e0397e718e9306b151001ae8"
    // URL에 "&lang=en"을 추가하여 API 응답을 영어로 받도록 수정합니다.
    let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric&lang=en"

    guard let url = URL(string: urlString) else {
        print("URL creation failed")
        return
    }

    URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data {
            do {
                let result = try JSONDecoder().decode(ForecastWeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(result.list)
                }
            } catch {
                print("Decoding Error: \(error)")
            }
        } else {
            print("No data or error: \(error?.localizedDescription ?? "Unknown error")")
        }
    }.resume()
}
