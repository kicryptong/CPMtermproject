// MemoInputView.swift

import SwiftUI

struct MemoInputView: View {
    @EnvironmentObject var weatherLogManager: WeatherLogManager
    @Environment(\.dismiss) var dismiss

    let weather: Weather

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 15) {
                Text("Log Current Weather Information")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Location: \(weather.location)")
                    Text("Temperature: \(weather.temperature)°C")
                    Text("Condition: \(weather.description)")
                    Text("Wind Speed: \(String(format: "%.1f", weather.windSpeed)) m/s")
                }
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
                
                Text("Press 'Confirm & Save' to log the current weather information without a memo.")
                    .font(.callout)
                    .padding(.vertical)

                Spacer()
            }
            .padding()
            .navigationTitle("Confirm Weather Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Confirm & Save") {
                        saveLogWithoutMemoAndDismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    private func saveLogWithoutMemoAndDismiss() {
        weatherLogManager.addLog(
            weather: weather,
            locationName: weather.location,
            memo: nil
        )
        dismiss()
    }
}
