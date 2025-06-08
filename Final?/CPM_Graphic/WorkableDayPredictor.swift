// WorkableDayPredictor.swift

import Foundation

struct DailyWorkPrediction: Identifiable {
    let id = UUID()
    let date: Date
    var isWorkable: Bool
    var reasons: [String]
    var isBeyondForecastHorizon: Bool = false
}

class WorkableDayPredictor {

    private let maxSafeTempBeforeNonWorkable: Double = 33.0
    private let minSafeTempBeforeNonWorkable: Double = 5.0
    private let maxSafeWindSpeedBeforeNonWorkable: Double = 10.0
    private let nonWorkableWeatherConditions: [String] = [
        "Rain", "Snow", "Drizzle", "Thunderstorm",
        "Squall", "Tornado", "Sand", "Dust", "Ash",
        "Fog", "Mist", "Haze"
    ]

    private func isForecastItemWorkable(item: ForecastItem) -> (isWorkable: Bool, reasons: [String]) {
        var currentSlotIsWorkable = true
        var currentSlotReasons: [String] = []
        let weatherMainCondition = item.weather.first?.main ?? ""
        let weatherDescription = item.weather.first?.description ?? weatherMainCondition

        if nonWorkableWeatherConditions.contains(where: { $0.caseInsensitiveCompare(weatherMainCondition) == .orderedSame }) {
            currentSlotIsWorkable = false
            currentSlotReasons.append("Weather: \(weatherDescription)")
        }

        if item.main.temp >= maxSafeTempBeforeNonWorkable {
            currentSlotIsWorkable = false
            currentSlotReasons.append(String(format: "High Temp: %.1f°C", item.main.temp))
        }
        if item.main.temp <= minSafeTempBeforeNonWorkable {
            currentSlotIsWorkable = false
            currentSlotReasons.append(String(format: "Low Temp: %.1f°C", item.main.temp))
        }

        if item.wind.speed >= maxSafeWindSpeedBeforeNonWorkable {
            currentSlotIsWorkable = false
            currentSlotReasons.append(String(format: "High Wind: %.1f m/s", item.wind.speed))
        }
        
        return (currentSlotIsWorkable, currentSlotReasons)
    }

    public func generateDailyPredictions(
        forecastItems: [ForecastItem],
        forDaysAhead: Int,
        forecastAvailableUpToDays: Int = 5
    ) -> [DailyWorkPrediction] {
        
        var dailyPredictions: [DailyWorkPrediction] = []
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let groupedByDay = Dictionary(grouping: forecastItems) { item -> Date in
            calendar.startOfDay(for: item.date)
        }

        for dayOffset in 0..<forDaysAhead {
            guard let currentProcessingDay = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            
            let actualForecastEndDate = calendar.date(byAdding: .day, value: forecastAvailableUpToDays, to: today)!

            if currentProcessingDay < actualForecastEndDate {
                if let itemsForThisDay = groupedByDay[currentProcessingDay], !itemsForThisDay.isEmpty {
                    var overallDayIsWorkable = true
                    var combinedReasonsForDay: Set<String> = []

                    for forecastItem in itemsForThisDay {
                        let slotResult = isForecastItemWorkable(item: forecastItem)
                        if !slotResult.isWorkable {
                            overallDayIsWorkable = false
                            slotResult.reasons.forEach { combinedReasonsForDay.insert($0) }
                        }
                    }
                    dailyPredictions.append(DailyWorkPrediction(date: currentProcessingDay, isWorkable: overallDayIsWorkable, reasons: Array(combinedReasonsForDay)))
                } else {
                    dailyPredictions.append(DailyWorkPrediction(date: currentProcessingDay, isWorkable: true, reasons: ["No forecast data (within 5 days)"], isBeyondForecastHorizon: true))
                }
            } else {
                dailyPredictions.append(DailyWorkPrediction(date: currentProcessingDay, isWorkable: true, reasons: ["Beyond 5-day forecast (assumed clear)"], isBeyondForecastHorizon: true))
            }
        }
        return dailyPredictions
    }
}
