//
//  WorkableDayPredictor.swift
//  CPM_Graphic
//
//  Created by 성준영 on 6/1/25.
//


import Foundation

// 각 날짜별 공사 가능성 예측 결과를 담을 구조체
struct DailyWorkPrediction: Identifiable {
    let id = UUID()
    let date: Date // 날짜 (해당 날짜의 시작 시간 기준)
    var isWorkable: Bool // 공사 가능 여부
    var reasons: [String] // 공사 불가능할 경우의 이유 목록
    var isBeyondForecastHorizon: Bool = false // 실제 예보 기간(5일)을 넘어선 날짜인지 여부
}

class WorkableDayPredictor {

    // 공사 가능/불가능 판단 기준값들
    // 온도는 섭씨(°C), 풍속은 m/s 기준
    private let maxSafeTempBeforeNonWorkable: Double = 33.0 // 이 온도 '이상'이면 작업 중단 고려 (혹서)
    private let minSafeTempBeforeNonWorkable: Double = 5.0  // 이 온도 '이하'이면 작업 중단 고려 (혹한)
    private let maxSafeWindSpeedBeforeNonWorkable: Double = 10.0 // 이 풍속 '이상'이면 작업 중단 고려 (강풍)

    // 작업 중단을 고려해야 하는 주요 날씨 상태 (WeatherInfo.main 값 기준, 대소문자 구분 없이 비교)
    private let nonWorkableWeatherConditions: [String] = [
        "Rain", "Snow", "Drizzle", "Thunderstorm", // 강수 관련
        "Squall", "Tornado",                       // 악천후
        "Sand", "Dust", "Ash",                     // 분진, 화산재
        "Fog", "Mist", "Haze"                      // 시계 불량
    ]

    // 특정 3시간 단위 예보(ForecastItem)가 작업 가능한지 판단하는 내부 함수
    private func isForecastItemWorkable(item: ForecastItem) -> (isWorkable: Bool, reasons: [String]) {
        var currentSlotIsWorkable = true
        var currentSlotReasons: [String] = []
        let weatherMainCondition = item.weather.first?.main ?? ""
        let weatherDescription = item.weather.first?.description ?? weatherMainCondition

        // 1. 주요 날씨 상태 확인
        if nonWorkableWeatherConditions.contains(where: { $0.caseInsensitiveCompare(weatherMainCondition) == .orderedSame }) {
            currentSlotIsWorkable = false
            currentSlotReasons.append("날씨 상태: \(weatherDescription)")
        }

        // 2. 온도 확인 (혹서/혹한)
        if item.main.temp >= maxSafeTempBeforeNonWorkable {
            currentSlotIsWorkable = false
            currentSlotReasons.append(String(format: "높은 온도: %.1f°C", item.main.temp))
        }
        if item.main.temp <= minSafeTempBeforeNonWorkable {
            currentSlotIsWorkable = false
            currentSlotReasons.append(String(format: "낮은 온도: %.1f°C", item.main.temp))
        }

        // 3. 풍속 확인 (강풍)
        if item.wind.speed >= maxSafeWindSpeedBeforeNonWorkable {
            currentSlotIsWorkable = false
            currentSlotReasons.append(String(format: "강한 바람: %.1f m/s", item.wind.speed))
        }
        
        return (currentSlotIsWorkable, currentSlotReasons)
    }

    // 여러 날에 걸친 일별 공사 가능성 예측 목록 생성 함수
    public func generateDailyPredictions(
        forecastItems: [ForecastItem], // API로부터 받은 3시간 단위 예보 목록
        forDaysAhead: Int,             // 오늘부터 며칠 후까지 예측할지 (예: 7일, 14일)
        forecastAvailableUpToDays: Int = 5 // 실제 API 예보가 제공되는 최대 일수
    ) -> [DailyWorkPrediction] {
        
        var dailyPredictions: [DailyWorkPrediction] = []
        let calendar = Calendar.current
        // API에서 받아온 예보 데이터는 보통 현재 시점부터 시작하므로, 기준 날짜를 오늘로 잡습니다.
        // 더 정확하게는 forecastItems의 첫 번째 항목의 날짜를 기준으로 할 수도 있습니다.
        let today = calendar.startOfDay(for: Date())

        // 3시간 단위 예보(forecastItems)를 날짜별로 그룹핑합니다.
        let groupedByDay = Dictionary(grouping: forecastItems) { item -> Date in
            calendar.startOfDay(for: item.date)
        }

        // 지정된 forDaysAhead 만큼 반복하여 일별 예측을 생성합니다.
        for dayOffset in 0..<forDaysAhead {
            guard let currentProcessingDay = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            
            // 실제 예보가 끝나는 날짜 계산 (오늘 + forecastAvailableUpToDays)
            let actualForecastEndDate = calendar.date(byAdding: .day, value: forecastAvailableUpToDays, to: today)!

            if currentProcessingDay < actualForecastEndDate { // 실제 예보 기간(예: 5일) 이내인 경우
                if let itemsForThisDay = groupedByDay[currentProcessingDay], !itemsForThisDay.isEmpty {
                    // 해당 날짜에 대한 3시간 단위 예보들이 있다면
                    var overallDayIsWorkable = true
                    var combinedReasonsForDay: Set<String> = [] // Set을 사용해 중복 사유 방지

                    for forecastItem in itemsForThisDay {
                        let slotResult = isForecastItemWorkable(item: forecastItem)
                        if !slotResult.isWorkable {
                            overallDayIsWorkable = false
                            slotResult.reasons.forEach { combinedReasonsForDay.insert($0) }
                        }
                    }
                    dailyPredictions.append(DailyWorkPrediction(date: currentProcessingDay, isWorkable: overallDayIsWorkable, reasons: Array(combinedReasonsForDay)))
                } else {
                    // 예보 기간 이내인데 해당 날짜의 데이터가 없는 경우 (API 응답이 불완전하거나, 예보 시작/종료 시점 때문일 수 있음)
                    // 안전하게 작업 불가능으로 처리하거나, "데이터 없음"으로 표시할 수 있습니다.
                    // 여기서는 "데이터 없음"으로 표기하고, 작업 가능으로 가정합니다 (사용자 요청 반영).
                    dailyPredictions.append(DailyWorkPrediction(date: currentProcessingDay, isWorkable: true, reasons: ["예보 데이터 없음 (5일 이내)"], isBeyondForecastHorizon: true))
                }
            } else { // 실제 예보 기간(예: 5일)을 넘어선 경우
                // 사용자의 요청에 따라 "날씨 맑음 및 공사 가능"으로 가정합니다.
                dailyPredictions.append(DailyWorkPrediction(date: currentProcessingDay, isWorkable: true, reasons: ["5일 예보 기간 이후 (맑음 가정)"], isBeyondForecastHorizon: true))
            }
        }
        return dailyPredictions
    }
}
