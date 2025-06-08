
//
import SwiftUI

struct WeatherView: View {
    
    var openWeatherResponse: OpenWeatherResponse
    private var weather: Weather { // Computed property로 Weather 객체 생성
        Weather(response: openWeatherResponse)
    }
    
    @EnvironmentObject var weatherLogManager: WeatherLogManager
    
    // MARK: - 시트 표시를 위한 상태 변수
    @State private var showingMemoInputSheet = false

    // 기존 알림창 관련 상태 변수는 이제 필요 없습니다.
    // @State private var showingLogMemoAlert = false
    // @State private var logMemoText = ""

    private let iconList = [
        "Clear": "☀️",
        "Clouds": "☁️",
        "Mist": "🌫️",
        "Smoke": "🌫️",
        "Haze": "🌫️",
        "Dust": "💨",
        "Fog": "🌫️",
        "Sand": "💨",
        "Ash": "🌋",
        "Squall": "🌬️",
        "Tornado": "🌪️",
        "Drizzle": "🌧️",
        "Thunderstorm": "⛈️",
        "Rain": "🌧️",
        "Snow": "❄️"
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - 기본 날씨 정보
                Text(weather.location)
                    .font(.largeTitle)
                    .padding(.top)
                
                Text("\(weather.temperature)°C")
                    .font(.system(size: 70, weight: .bold))
                
                Text(iconList[weather.main] ?? "❓")
                    .font(.system(size: 60))
                
                Text(weather.description)
                    .font(.title2)
                
                Text("풍속: \(String(format: "%.1f", weather.windSpeed)) m/s")
                    .font(.title3)

                Divider()

                // MARK: - 건설 작업 조건 알림
                VStack(alignment: .leading, spacing: 10) {
                    Text("건설 작업 조건 알림")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 5)

                    if weather.main == "Rain" || weather.main == "Drizzle" || weather.main == "Snow" {
                        Text("⚠️ 강수/강설: 야외 작업 중단 고려 및 자재 보호 필요.")
                            .foregroundColor(.red)
                    }
                    
                    if let tempValue = Double(weather.temperature) {
                        if tempValue >= 33.0 { // 혹서 기준 (예시)
                            Text("🌡️ 혹서 주의: 작업자 온열 질환 예방 및 콘크리트 급격 양생 주의.")
                                .foregroundColor(.orange)
                        } else if tempValue <= 5.0 { // 혹한 기준 (예시)
                             Text("❄️ 혹한 주의: 작업자 저체온증 예방 및 동절기 자재 관리 철저.")
                                .foregroundColor(.blue)
                        }
                    }

                    if weather.windSpeed >= 10.0 { // 강풍 기준 (예시, 10m/s)
                        Text("💨 강풍 주의: 고소 작업, 크레인 작업 중지. 낙하물 발생 위험.")
                            .foregroundColor(.red)
                    }
                    
                    if weather.main == "Fog" || weather.main == "Mist" || weather.main == "Haze" {
                         Text("🌫️ 안개/연무: 시계 불량. 작업 시야 확보 및 안전에 유의.")
                            .foregroundColor(.gray)
                    }
                    
                    if !isAlertNeeded() {
                        Text("✅ 현재 날씨는 대부분의 야외 작업에 양호합니다.")
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)

                Divider()
                
                // MARK: - 날씨 기록 버튼 (시트 표시 방식으로 수정됨)
                Button {
                    // 알림창 대신 시트를 표시하도록 상태 변경
                    showingMemoInputSheet = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.pencil") // 아이콘 변경 (선택 사항)
                        Text("현재 날씨 기록 (메모 추가)")    // 버튼 텍스트 변경
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom)

            } // VStack
        } // ScrollView
        // MARK: - 기존 알림창 로직 제거
        // .alert(...)
        // MARK: - 메모 입력 시트 추가
        .sheet(isPresented: $showingMemoInputSheet) {
            // MemoInputView에 현재 weather 객체를 전달합니다.
            // weatherLogManager는 이미 환경 객체로 MemoInputView에 주입됩니다.
            MemoInputView(weather: self.weather)
        }
    }
    
    // 알림 필요 여부 판단 함수 (내용 변경 없음)
    private func isAlertNeeded() -> Bool {
        if weather.main == "Rain" || weather.main == "Drizzle" || weather.main == "Snow" {
            return true
        }
        if let tempValue = Double(weather.temperature) {
            if tempValue >= 33.0 || tempValue <= 5.0 {
                return true
            }
        }
        if weather.windSpeed >= 10.0 {
            return true
        }
        if weather.main == "Fog" || weather.main == "Mist" || weather.main == "Haze" {
            return true
        }
        return false
    }
}

// PreviewProvider는 필요시 위 MemoInputView_Previews와 유사하게 수정 가능합니다.
// struct WeatherView_Previews: PreviewProvider {
//    static var previews: some View {
//        let exampleMain = OpenWeatherMain(temp: 20.0, feels_like: 19.0, temp_min: 18.0, temp_max: 22.0, pressure: 1012, humidity: 60)
//        let exampleWeatherDesc = OpenWeatherWeather(id: 800, description: "맑음", main: "Clear", icon: "01d")
//        let exampleWind = OpenWeatherWind(speed: 3.5, deg: 180, gust: 5.0)
//        let exampleResponse = OpenWeatherResponse(name: "서울", main: exampleMain, weather: [exampleWeatherDesc], wind: exampleWind)
//
//        WeatherView(openWeatherResponse: exampleResponse)
//            .environmentObject(WeatherLogManager())
//    }
// }
