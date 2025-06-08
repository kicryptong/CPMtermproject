

import Foundation
import CoreLocation

class WeatherDataDownload {
    
    private let API_KEY = "5100de82d81f62da14faa8c12caa2315" // !!!!! 여기에 실제 OpenWeatherMap API 키를 입력하세요 !!!!!

    func getWeather(location: CLLocationCoordinate2D) async throws -> OpenWeatherResponse {
        // API 요청 시 언어 설정을 추가하여 설명을 한국어로 받을 수 있습니다. (예: &lang=kr)
        let urlStringWithLang = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.latitude)&lon=\(location.longitude)&appid=\(API_KEY)&units=metric&lang=kr"
        
        guard let urlString = urlStringWithLang.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            fatalError("URL string 인코딩 실패") // 오류 메시지 구체화
        }

        guard let url = URL(string: urlString) else {
            fatalError("유효하지 않은 URL: \(urlString)") // 오류 메시지 구체화
        }
        
        let urlRequest = URLRequest(url: url)
        
        print("Requesting Weather URL: \(url)") // 요청 URL 로그 출력 (디버깅용)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            fatalError("잘못된 응답 유형")
        }
        
        print("Response Status Code: \(httpResponse.statusCode)") // 상태 코드 로그 출력

        guard httpResponse.statusCode == 200 else {
            // API 오류 응답 본문 출력 (디버깅에 유용)
            if let responseBody = String(data: data, encoding: .utf8) {
                print("API Error Response Body: \(responseBody)")
            }
            fatalError("날씨 데이터 가져오기 오류 - 상태 코드: \(httpResponse.statusCode)")
        }
                
        do {
            let decodedData = try JSONDecoder().decode(OpenWeatherResponse.self, from: data)
            return decodedData
        } catch let decodingError {
            print("JSON 디코딩 오류: \(decodingError)") // 디코딩 오류 상세 로그
            // 디코딩 실패 시 데이터 내용 출력 (구조 확인용)
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Failed to decode JSON: \(jsonString)")
            }
            throw decodingError // 오류를 다시 던져서 호출한 곳에서 처리하도록 함
        }
    }
}
