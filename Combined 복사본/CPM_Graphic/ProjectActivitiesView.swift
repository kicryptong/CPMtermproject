// ProjectActivitiesView.swift

import SwiftData
import SwiftUI

struct ProjectActivitiesView: View {
    @Environment(\.modelContext) var modelContext
    @State private var path = NavigationPath()
    @State private var projectResult: String?
    @State private var isShowingProjectResults = false
    @State private var startDateInput: String = "1" // 초기값 또는 이전 값 유지
    @State private var isShowingMonthlyCost = false
    
    var daysRemaining: Int? {
        guard
            let startOffset = Int(startDateInput),
            let startDate = Calendar.current.date(byAdding: .day, value: startOffset, to: Date())
        else {
            return nil
        }
        
        let projectDuration = activities.map { $0.earlyFinish }.max() ?? 0
        guard let endDate = Calendar.current.date(byAdding: .day, value: projectDuration, to: startDate) else {
            return nil
        }

        let today = Calendar.current.startOfDay(for: Date())
        let remaining = Calendar.current.dateComponents([.day], from: today, to: endDate).day ?? 0
        return remaining >= 0 ? remaining : 0
    }
    
    @Query(sort: [
        SortDescriptor(\Activity.id),
        SortDescriptor(\Activity.name)
    ]) var activities: [Activity]
    
    var body: some View {
        VStack(spacing: 0) {
            Image("infraSyncLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 50)
                .padding(.top, 2)
                .padding(.bottom, 0)
            
            // Navigation stack with main content
            NavigationStack(path: $path) {
                VStack(spacing: 8) {
                    ProjectView(startDateInput: $startDateInput)
                    
                    // ⬇️ Remaining days shown AFTER the activity list
                            if let days = daysRemaining {
                                Text("📆 Remaining Days: \(days)")
                                    .font(.subheadline)
                                    .padding(.bottom, 50)
                            }
                        }
                    .navigationTitle("Activity List")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                calculateSchedule()
                            } label: {
                                Label("Schedule", systemImage: "calendar")
                                    .font(.custom("HelveticaNeue-Bold", size: 16))
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                addActivity()
                            } label: {
                                Label("Add Activity", systemImage: "plus")
                                    .font(.custom("HelveticaNeue-Bold", size: 16))
                            }
                        }
                        ToolbarItem(placement: .bottomBar) {
                            Button {
                                isShowingMonthlyCost = true
                            } label: {
                                Label("Coûts Mensuels", systemImage: "chart.bar.doc.horizontal")
                                    .font(.custom("HelveticaNeue-Bold", size: 14))
                            }
                        }
                    }
                    .navigationDestination(for: Activity.self) { activity in
                        EditActivityView(navigationPath: $path, activity: activity)
                    }
                    .navigationDestination(isPresented: $isShowingProjectResults) {
                        if let resultString = projectResult {
                            ProjectResultView(resultString: resultString)
                        }
                    }
                    .navigationDestination(isPresented: $isShowingMonthlyCost) {
                        let duration = activities.map { $0.earlyFinish }.max() ?? 0
                        let costs = monthlyCostBreakdown(for: activities, projectDuration: duration)
                        let billed = monthlyTotalBilled(for: activities, projectDuration: duration)
                        
                        MonthlyCostView(
                            monthlyCosts: costs,
                            monthlyTotalBilled: billed
                        )
                    }
                
            }
        }
    }



    
    func addActivity() {
        let newId = (activities.max(by: { $0.id < $1.id })?.id ?? 0) + 1
        let activity = Activity(id: newId, name: "", duration: 0)
        modelContext.insert(activity)
        path.append(activity)
    }
    
    func calculateSchedule() {
        guard let startDate = Int(startDateInput) else {
            print("시작일은 숫자로 입력해야 합니다.")
            return
        }
        let schedule = Schedule(startDate: startDate, schedule: activities)
        let project = Project(schedules: [schedule])
        project.scheduleCalculation()
        projectResult = project.result
        isShowingProjectResults = true
    }
    
    func monthlyTotalBilled(for activities: [Activity], projectDuration: Int) -> [Int: Double] {
        var billedByMonth: [Int: Double] = [:]
        
        let daysInMonth = 30
        let numberOfMonths = Int(ceil(Double(projectDuration) / Double(daysInMonth)))
        
        for month in 1...numberOfMonths {
            let monthStart = (month - 1) * daysInMonth
            let monthEnd = month * daysInMonth - 1
            
            var billedSum: Double = 0
            
            for activity in activities {
                let activityStart = activity.earlyStart
                let activityEnd = activity.earlyFinish
                
                if activityEnd < monthStart || activityStart > monthEnd {
                    continue
                }

                let effectiveStart = max(monthStart, activityStart)
                let effectiveEnd = min(monthEnd, activityEnd)
                let activeDays = max(0, effectiveEnd - effectiveStart + 1)

                let dailyBilled = activity.totalBilled / Double(activity.duration)
                billedSum += Double(activeDays) * dailyBilled
            }
            
            billedByMonth[month] = billedSum
        }
        
        return billedByMonth
    }

}

