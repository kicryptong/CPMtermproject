// ProjectView.swift

import SwiftData
import SwiftUI

struct ProjectView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: [
        SortDescriptor(\Activity.id),
        SortDescriptor(\Activity.name)
    ]) var activities: [Activity]
    @Binding var startDateInput: String

    var body: some View {
        VStack(spacing: 16) {
            TextField("Start Date", text: $startDateInput)
                .keyboardType(.numberPad)
                .padding(12)
                .background(Color.white.opacity(0.8))
                .cornerRadius(8)
                .font(.custom("HelveticaNeue", size: 18))

            List {
                ForEach(activities) { activity in
                    NavigationLink(value: activity) {
                        Text("ID: \(activity.id), Name: \(activity.name)")
                            .font(.custom("HelveticaNeue-Medium", size: 16))
                            .padding(.vertical, 8)
                    }
                }
                .onDelete(perform: deleteActivity)
            }
            .listStyle(.insetGrouped)
            .background(Color.clear)
        }
        .padding()
        .background(
            Image("ArchitectureBackground")
                .resizable()
                .scaledToFill()
                .opacity(0.2)
        )
    }

    func deleteActivity(at offsets: IndexSet) {
        for offset in offsets {
            let activity = activities[offset]
            modelContext.delete(activity)
        }
    }
}
