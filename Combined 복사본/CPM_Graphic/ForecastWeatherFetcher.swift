//
//  ForecastWeatherFetcher.swift
//  NewWeather
//
//  Created by snlcom on 5/28/25.
//
//
//  WeatherForecastDownload.swift
//  YourWeatherApp
//
//  Created by YourName on 2025/05/30.
//

import Foundation

func fetchForecastWeather(lat: Double, lon: Double, completion: @escaping ([ForecastItem]) -> Void) {
    let apiKey = "f5e18905e0397e718e9306b151001ae8"
    let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric"

    guard let url = URL(string: urlString) else {
        print("URL 생성 실패")
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
                print("디코딩 에러: \(error)")
            }
        } else {
            print("데이터 없음 또는 오류: \(error?.localizedDescription ?? "알 수 없는 오류")")
        }
    }.resume()
}
