import SwiftUI

struct ForecastView: View {
    @State private var dailyWorkPredictions: [DailyWorkPrediction] = []
    private let predictor = WorkableDayPredictor()
    @State private var isLoading = true

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    // ✅ 팝업 상태 관리
    @State private var selectedPrediction: DailyWorkPrediction? = nil
    @State private var showDetailSheet = false

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView("예보 및 공사 가능성 분석 중...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
            } else if dailyWorkPredictions.isEmpty {
                Text("분석할 예보 데이터가 없거나, 공사 가능성 정보를 가져올 수 없습니다.")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("공사 가능성 예보 (2주)")
                        .font(.title2)
                        .bold()
                        .padding(.leading)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(dailyWorkPredictions) { prediction in
                            let isToday = Calendar.current.isDateInToday(prediction.date)

                            // ✅ 셀을 버튼으로 변경해 상세 보기 가능하도록
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
                                    // ✅ 오늘이면 파란 테두리 추가
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
        .navigationTitle("공사 가능성 달력")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchAndPredictWorkability()
        }
        // ✅ 상세 팝업
        .sheet(isPresented: $showDetailSheet) {
            if let prediction = selectedPrediction {
                DetailPredictionView(prediction: prediction)
            }
        }
    }

    private func fetchAndPredictWorkability() {
        isLoading = true
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
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M.d(E)"
        return formatter.string(from: date)
    }
}
