// ForecastView.swift

import SwiftUI

struct ForecastView: View {
    @State private var dailyWorkPredictions: [DailyWorkPrediction] = []
    private let predictor = WorkableDayPredictor()
    @State private var isLoading = true

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    @State private var selectedPrediction: DailyWorkPrediction? = nil
    @State private var showDetailSheet = false

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView("Analyzing forecast and workability...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
            } else if dailyWorkPredictions.isEmpty {
                Text("No forecast data to analyze or workability information is unavailable.")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Workability Forecast (2 Weeks)")
                        .font(.title2)
                        .bold()
                        .padding([.leading, .top])

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(dailyWorkPredictions) { prediction in
                            let isToday = Calendar.current.isDateInToday(prediction.date)

                            Button {
                                selectedPrediction = prediction
                                showDetailSheet = true
                            } label: {
                                VStack(spacing: 6) {
                                    Text(formattedShortDate(prediction.date))
                                        .font(.caption)
                                        .foregroundColor(.primary)

                                    Image(systemName: prediction.isWorkable ? "checkmark.circle.fill" : "xmark.octagon.fill")
                                        .foregroundColor(prediction.isWorkable ? .green : .red)
                                        .font(.title2)

                                    if !prediction.reasons.isEmpty {
                                        Text(prediction.reasons.first ?? "")
                                            .font(.caption2)
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.gray)
                                            .lineLimit(2)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .background(prediction.isWorkable ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(isToday ? Color.blue : Color.clear, lineWidth: 2)
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Workability Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchAndPredictWorkability()
        }
        .sheet(isPresented: $showDetailSheet) {
            if let prediction = selectedPrediction {
                DetailPredictionView(prediction: prediction)
            }
        }
    }

    private func fetchAndPredictWorkability() {
        isLoading = true
        // 서울의 위도/경도로 예시
        fetchForecastWeather(lat: 37.5665, lon: 126.9780) { forecastItems in
            self.dailyWorkPredictions = predictor.generateDailyPredictions(
                forecastItems: forecastItems,
                forDaysAhead: 14,
                forecastAvailableUpToDays: 5
            )
            isLoading = false
        }
    }

    private func formattedShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        // Locale을 영어로 변경하여 요일이 "Mon", "Tue" 등으로 표시되게 합니다.
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "M/d (E)"
        return formatter.string(from: date)
    }
}
