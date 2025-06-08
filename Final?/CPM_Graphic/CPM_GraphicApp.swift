// CPM_GraphicApp.swift

import SwiftUI

@main
struct CPM_GraphicApp: App {
    @StateObject var locationManager = LocationManager() // 날씨 기능용
    @StateObject var weatherLogManager = WeatherLogManager() // 날씨 기록 기능용

    var body: some Scene {
        WindowGroup {
            MainTabView() // 새로운 메인 TabView를 사용합니다.
                .accentColor(.orange) // 강조 색상 유지
                .environmentObject(locationManager) // 환경 객체로 주입
                .environmentObject(weatherLogManager) // 환경 객체로 주입
                .background( // 배경 이미지는 MainTabView 내부 또는 각 탭 최상단 뷰로 이동 고려
                    Image("ArchitectureBackground")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                )
        }
        .modelContainer(for: Activity.self) // SwiftData 모델 컨테이너 유지
    }
}
