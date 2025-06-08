// WeatherDashboardView.swift

import SwiftUI

struct WeatherDashboardView: View {
    
    @EnvironmentObject var locationManager : LocationManager
    @EnvironmentObject var weatherLogManager : WeatherLogManager
    @Environment(\.dismiss) var dismiss

    
    var weatherDataDownload = WeatherDataDownload()
    @State var openWeatherResponse : OpenWeatherResponse?
    
    @State private var showingLogList = false
    
    var body: some View {
        // 디버깅 print 문: 뷰 상태 확인
        let _ = print("WeatherDashboardView: locationManager.location is \(locationManager.location != nil ? "(\(locationManager.location!.latitude), \(locationManager.location!.longitude))" : "nil"), locationManager.isLoading: \(locationManager.isLoading), openWeatherResponse is \(openWeatherResponse == nil ? "nil" : "not nil")")
        
        return NavigationView {
            VStack {
                if let location = locationManager.location {
                    // 디버깅 print 문: 위치 정보 확인
                    let _ = print("WeatherDashboardView: Location found - \(location.latitude), \(location.longitude)")
                    if let openWeatherResponse = openWeatherResponse {
                        // 디버깅 print 문: 날씨 응답 확인
                        let _ = print("WeatherDashboardView: Weather response found, showing WeatherView.")
                        WeatherView(openWeatherResponse: openWeatherResponse)
                            .environmentObject(weatherLogManager)

                        NavigationLink(destination: ForecastView()) {
                            Text("📅 날씨 예보 보기")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    } else {
                        // 디버깅 print 문: 날씨 응답 대기 중
                        let _ = print("WeatherDashboardView: Location found, but no weather response yet. Showing ProgressView.")
                        ProgressView("날씨 정보 가져오는 중...")
                            .task {
                                do {
                                    // 디버깅 print 문: 날씨 정보 가져오기 시도
                                    print("WeatherDashboardView: Task started to get weather for location: \(location)")
                                    openWeatherResponse = try await weatherDataDownload.getWeather(location: location)
                                    // 디버깅 print 문: 날씨 정보 가져오기 성공
                                    print("WeatherDashboardView: Weather data fetched successfully.")
                                } catch {
                                    // 디버깅 print 문: 날씨 정보 가져오기 실패
                                    print("WeatherDashboardView: Failed to get weather - Error: \(error), Localized Description: \(error.localizedDescription)")
                                }
                            }
                    }
                } else {
                    if locationManager.isLoading {
                        // 디버깅 print 문: 위치 정보 로딩 중
                        let _ = print("WeatherDashboardView: Location not found, location manager is loading. Showing ProgressView.")
                        ProgressView("위치 정보 가져오는 중...")
                    } else {
                        // 디버깅 print 문: 위치 정보 없음, FirstView 표시
                        let _ = print("WeatherDashboardView: Location not found, location manager not loading. Showing FirstView.")
                        FirstView()
                    }
                }
            }
            .navigationTitle("오늘의 날씨")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingLogList = true
                    } label: {
                        Image(systemName: "list.bullet.clipboard")
                        Text("기록")
                    }
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("뒤로") // "Back" in Korean
                        }
                    }
                }
            }
            .sheet(isPresented: $showingLogList) {
                WeatherLogListView()
                    .environmentObject(weatherLogManager)
            }
        }
    }
}
