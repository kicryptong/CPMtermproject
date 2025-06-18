// WeatherView.swift

import SwiftUI

struct WeatherView: View {
    
    var openWeatherResponse: OpenWeatherResponse
    private var weather: Weather {
        Weather(response: openWeatherResponse)
    }
    
    @EnvironmentObject var weatherLogManager: WeatherLogManager
    @State private var showingMemoInputSheet = false

    private let iconList = [
        "Clear": "☀️", "Clouds": "☁️", "Mist": "🌫️", "Smoke": "🌫️",
        "Haze": "🌫️", "Dust": "💨", "Fog": "🌫️", "Sand": "💨",
        "Ash": "🌋", "Squall": "🌬️", "Tornado": "🌪️", "Drizzle": "🌧️",
        "Thunderstorm": "⛈️", "Rain": "🌧️", "Snow": "❄️"
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(weather.location)
                    .font(.largeTitle)
                    .padding(.top)
                
                Text("\(weather.temperature)°C")
                    .font(.system(size: 70, weight: .bold))
                
                Text(iconList[weather.main] ?? "❓")
                    .font(.system(size: 60))
                
                Text(weather.description)
                    .font(.title2)
                
                Text("Wind Speed: \(String(format: "%.1f", weather.windSpeed)) m/s")
                    .font(.title3)

                Divider()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Construction Work Alerts")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 5)

                    if weather.main == "Rain" || weather.main == "Drizzle" || weather.main == "Snow" {
                        Text("⚠️ Precipitation: Consider stopping outdoor work and protecting materials.")
                            .foregroundColor(.red)
                    }
                    
                    if let tempValue = Double(weather.temperature) {
                        if tempValue >= 33.0 {
                            Text("🌡️ Heat Warning: Prevent heat illness and watch for rapid concrete curing.")
                                .foregroundColor(.orange)
                        } else if tempValue <= 5.0 {
                             Text("❄️ Cold Warning: Prevent hypothermia and manage winter materials.")
                                .foregroundColor(.blue)
                        }
                    }

                    if weather.windSpeed >= 10.0 {
                        Text("💨 High Winds: Stop high-altitude work and crane operations due to falling object risk.")
                            .foregroundColor(.red)
                    }
                    
                    if weather.main == "Fog" || weather.main == "Mist" || weather.main == "Haze" {
                         Text("🌫️ Low Visibility: Ensure clear sightlines and work safely in foggy conditions.")
                            .foregroundColor(.gray)
                    }
                    
                    if !isAlertNeeded() {
                        Text("✅ Current weather is favorable for most outdoor work.")
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)

                Divider()
                
                Button {
                    showingMemoInputSheet = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.pencil")
                        Text("Log Current Weather (Add Memo)")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .sheet(isPresented: $showingMemoInputSheet) {
            MemoInputView(weather: self.weather)
        }
    }
    
    private func isAlertNeeded() -> Bool {
        if ["Rain", "Drizzle", "Snow", "Fog", "Mist", "Haze"].contains(weather.main) { return true }
        if let temp = Double(weather.temperature), temp >= 33.0 || temp <= 5.0 { return true }
        if weather.windSpeed >= 10.0 { return true }
        return false
    }
}
