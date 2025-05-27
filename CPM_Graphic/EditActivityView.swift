// EditActivityView.swift

import SwiftData
import SwiftUI

struct EditActivityView: View {
    @Binding var navigationPath: NavigationPath
    @Bindable var activity: Activity

    @State private var selectedPredecessorId: Int?
    @State private var selectedSuccessorId: Int?

    @Query(sort: [
        SortDescriptor(\Activity.id),
        SortDescriptor(\Activity.name)
    ]) var activities: [Activity]

    var body: some View {
        Form {
            // 1. General Information
            Section(header:
                Text("GENERAL INFORMATION")
                    .font(.custom("HelveticaNeue-Bold", size: 18))
            ) {
                HStack {
                    Text("ID:")
                        .font(.custom("HelveticaNeue", size: 16))
                    Spacer()
                    TextField("ID", value: $activity.id, formatter: NumberFormatter())
                        .font(.custom("HelveticaNeue", size: 16))
                }
                HStack {
                    Text("Name:")
                        .font(.custom("HelveticaNeue", size: 16))
                    Spacer()
                    TextField("Name", text: $activity.name)
                        .font(.custom("HelveticaNeue", size: 16))
                }
                HStack {
                    Text("Duration:")
                        .font(.custom("HelveticaNeue", size: 16))
                    Spacer()
                    TextField("Duration", value: $activity.duration, formatter: NumberFormatter())
                        .font(.custom("HelveticaNeue", size: 16))
                        .keyboardType(.numberPad)
                }
            }

            // 2. Predecessors
            Section(header:
                Text("PREDECESSORS")
                    .font(.custom("HelveticaNeue-Bold", size: 18))
            ) {
                if activity.predecessors.isEmpty {
                    Text("No predecessors")
                        .font(.custom("HelveticaNeue-Italic", size: 16))
                } else {
                    ForEach(activity.predecessors.sorted(by: { $0.id < $1.id }), id: \.id) { pred in
                        Text(pred.name)
                            .font(.custom("HelveticaNeue", size: 16))
                    }
                    .onDelete(perform: removePredecessor)
                }

                Picker("Select New Predecessor", selection: $selectedPredecessorId) {
                    Text("None").tag(nil as Int?)
                    ForEach(activities.filter { $0.id != activity.id }, id: \.id) { act in
                        Text("\(act.name) (\(act.id))")
                            .tag(act.id as Int?)
                    }
                }
                .onChange(of: selectedPredecessorId) { _ in addPredecessor() }
                .font(.custom("HelveticaNeue", size: 16))
            }

            // 3. Successors
            Section(header:
                Text("SUCCESSORS")
                    .font(.custom("HelveticaNeue-Bold", size: 18))
            ) {
                if activity.successors.isEmpty {
                    Text("No successors")
                        .font(.custom("HelveticaNeue-Italic", size: 16))
                } else {
                    ForEach(activity.successors.sorted(by: { $0.id < $1.id }), id: \.id) { succ in
                        Text(succ.name)
                            .font(.custom("HelveticaNeue", size: 16))
                    }
                    .onDelete(perform: removeSuccessor)
                }

                Picker("Select New Successor", selection: $selectedSuccessorId) {
                    Text("None").tag(nil as Int?)
                    ForEach(activities.filter { $0.id != activity.id }, id: \.id) { act in
                        Text("\(act.name) (\(act.id))")
                            .tag(act.id as Int?)
                    }
                }
                .onChange(of: selectedSuccessorId) { _ in addSuccessor() }
                .font(.custom("HelveticaNeue", size: 16))
            }

            // 4. Cost
            Section(header:
                Text("COST (USD)")
                    .font(.custom("HelveticaNeue-Bold", size: 18))
            ) {
                HStack {
                    Text("Material Cost:")
                    Spacer()
                    TextField("0.00", value: $activity.materialCost, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                }
                HStack {
                    Text("Overhead Cost:")
                    Spacer()
                    TextField("0.00", value: $activity.overheadCost, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                }
                HStack {
                    Text("Equipment Cost:")
                    Spacer()
                    TextField("0.00", value: $activity.equipmentCost, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                }
                HStack {
                    Text("Number of Workers:")
                    Spacer()
                    TextField("0", value: $activity.laborCount, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                }
                HStack {
                    Text("Total Cost:")
                        .font(.custom("HelveticaNeue-Bold", size: 16))
                    Spacer()
                    Text(activity.totalCost, format: .currency(code: "USD"))
                        .font(.custom("HelveticaNeue-Bold", size: 16))
                }
            }
        }
        .navigationTitle("Edit Activity")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: EditButton())
        .background(Color(.systemGroupedBackground).opacity(0.95))
    }

    private func addPredecessor() {
        guard let id = selectedPredecessorId,
              let pred = activities.first(where: { $0.id == id }) else { return }
        activity.predecessors += [pred]
        selectedPredecessorId = nil
    }
    private func removePredecessor(at offsets: IndexSet) {
        var temp = activity.predecessors
        temp.remove(atOffsets: offsets)
        activity.predecessors = temp
    }
    private func addSuccessor() {
        guard let id = selectedSuccessorId,
              let succ = activities.first(where: { $0.id == id }) else { return }
        activity.successors += [succ]
        selectedSuccessorId = nil
    }
    private func removeSuccessor(at offsets: IndexSet) {
        var temp = activity.successors
        temp.remove(atOffsets: offsets)
        activity.successors = temp
    }
}

