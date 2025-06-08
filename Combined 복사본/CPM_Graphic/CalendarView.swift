import SwiftUI

struct CalendarView: View {
    var startDate: Date
    var activities: [Activity]
    
    let calendar = Calendar.current
    
    // 📅 Generate date-activity mapping
    var scheduledByDate: [Date: [Activity]] {
        var map: [Date: [Activity]] = [:]
        for activity in activities {
            for dayOffset in 0..<activity.duration {
                let dayNumber = activity.earlyStart + dayOffset
                if let date = calendar.date(byAdding: .day, value: dayNumber, to: startDate) {
                    map[calendar.startOfDay(for: date), default: []].append(activity)
                }
            }
        }
        return map
    }
    
    // 📆 Create a date range from start to last scheduled day
    var displayedDates: [Date] {
        guard let maxDay = activities.map({ $0.earlyStart + $0.duration }).max() else { return [] }
        return (0..<maxDay).compactMap {
            calendar.date(byAdding: .day, value: $0, to: startDate)
        }
    }

    // 📦 Group into weeks
    var weeks: [[Date]] {
        var days = displayedDates
        var result: [[Date]] = []

        while !days.isEmpty {
            var week: [Date] = []
            for _ in 0..<7 {
                if let day = days.first {
                    week.append(day)
                    days.removeFirst()
                } else {
                    week.append(Date.distantPast)  // empty placeholder
                }
            }
            result.append(week)
        }
        return result
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Activity Calendar")
                    .font(.title)
                    .padding(.top)

                // Day headers
                HStack {
                    ForEach(calendar.shortWeekdaySymbols, id: \.self) { symbol in
                        Text(symbol)
                            .frame(maxWidth: .infinity)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                // Weekly rows
                ForEach(weeks, id: \.self) { week in
                    HStack(spacing: 8) {
                        ForEach(week, id: \.self) { date in
                            VStack(alignment: .leading, spacing: 4) {
                                if date == Date.distantPast {
                                    Color.clear.frame(height: 60)
                                } else {
                                    Text(formattedDay(date))
                                        .font(.caption)
                                        .bold()
                                    ForEach(scheduledByDate[calendar.startOfDay(for: date)] ?? [], id: \.id) { activity in
                                        Text(activity.name)
                                            .font(.caption2)
                                            .padding(2)
                                            .background(Color.blue.opacity(0.2))
                                            .cornerRadius(4)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .padding(6)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 1)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
    }

    func formattedDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
}

