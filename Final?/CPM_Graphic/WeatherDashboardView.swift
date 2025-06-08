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
        let _ = print("WeatherDashboardView: locationManager.location is \(locationManager.location != nil ? "(\(locationManager.location!.latitude), \(locationManager.location!.longitude))" : "nil"), locationManager.isLoading: \(locationManager.isLoading), openWeatherResponse is \(openWeatherResponse == nil ? "nil" : "not nil")")
        
        return NavigationView {
            VStack {
                if let location = locationManager.location {
                    let _ = print("WeatherDashboardView: Location found - \(location.latitude), \(location.longitude)")
                    if let openWeatherResponse = openWeatherResponse {
                        let _ = print("WeatherDashboardView: Weather response found, showing WeatherView.")
                        WeatherView(openWeatherResponse: openWeatherResponse)
                            .environmentObject(weatherLogManager)

                        NavigationLink(destination: ForecastView()) {
                            Text("📅 View Weather Forecast")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    } else {
                        let _ = print("WeatherDashboardView: Location found, but no weather response yet. Showing ProgressView.")
                        ProgressView("Fetching weather information...")
                            .task {
                                do {
                                    print("WeatherDashboardView: Task started to get weather for location: \(location)")
                                    openWeatherResponse = try await weatherDataDownload.getWeather(location: location)
                                    print("WeatherDashboardView: Weather data fetched successfully.")
                                } catch {
                                    print("WeatherDashboardView: Failed to get weather - Error: \(error), Localized Description: \(error.localizedDescription)")
                                 }
                            }
                    }
                } else {
                    if locationManager.isLoading {
                        let _ = print("WeatherDashboardView: Location not found, location manager is loading. Showing ProgressView.")
                        ProgressView("Fetching location information...")
                    } else {
                        let _ = print("WeatherDashboardView: Location not found, location manager not loading. Showing FirstView.")
                        FirstView()
                    }
                }
            }
            .navigationTitle("Today's Weather")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingLogList = true
                    } label: {
                        Image(systemName: "list.bullet.clipboard")
                        Text("Logs")
                    }
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
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
