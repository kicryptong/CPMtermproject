// ContentView.swift

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @State private var path = NavigationPath()
    @State private var projectResult: String?
    @State private var isShowingProjectResults = false
    @State private var startDateInput: String = "1"
    
    @Query(sort: [
        SortDescriptor(\Activity.id),
        SortDescriptor(\Activity.name)
    ]) var activities: [Activity]
    
    var body: some View {
        NavigationStack(path: $path) {
            ProjectView(startDateInput: $startDateInput)
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
                }
                .navigationDestination(for: Activity.self) { activity in
                    EditActivityView(navigationPath: $path, activity: activity)
                }
                .navigationDestination(isPresented: $isShowingProjectResults) {
                    if let resultString = projectResult {
                        ProjectResultView(resultString: resultString)
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
        guard let startDate = Int(startDateInput) else { return }
        let schedule = Schedule(startDate: startDate, schedule: activities)
        let project = Project(schedules: [schedule])
        project.scheduleCalculation()
        projectResult = project.result
        isShowingProjectResults = true
    }
}
