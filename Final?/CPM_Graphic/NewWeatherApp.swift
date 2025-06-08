// NewWeatherApp.swift
import SwiftUI

//@main
struct NewWeatherApp: App {
    
    @StateObject var locationManager = LocationManager()
    @StateObject var weatherLogManager = WeatherLogManager()

    var body: some Scene {
        WindowGroup {
            // ContentView() 대신, 간단한 텍스트로 대체하여 오류를 해결합니다.
            Text("NewWeatherApp (Not in use)")
                .environmentObject(locationManager) // 이 환경 객체 주입은 실제로 사용되진 않습니다.
                .environmentObject(weatherLogManager) // 이 환경 객체 주입은 실제로 사용되진 않습니다.
        }
    }
}
