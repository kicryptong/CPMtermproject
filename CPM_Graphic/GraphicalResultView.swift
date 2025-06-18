import SwiftData
import SwiftUI

struct GraphicalResultView: View {
    @Query(sort: [
        SortDescriptor(\Activity.id),
        SortDescriptor(\Activity.name)
    ]) var activities: [Activity]
    
    @EnvironmentObject var activityPositions: ActivityPositions
    @Environment(\.dismiss) var dismiss  // Needed for Back button
    
    @State private var projectStartDate = Date()
    @State private var showDatePicker = false
    @State private var navigateToCalendar = false

    private func groupedAndSortedActivities() -> [[Activity]] {
        Dictionary(grouping: activities) { $0.earlyStart }
            .sorted { $0.key < $1.key }
            .map { $0.value }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(spacing: 16) {
                        // 🔷 CPM Diagram
                        ZStack(alignment: .topLeading) {
                            VStack(spacing: 16) {
                                ForEach(groupedAndSortedActivities(), id: \.self) { group in
                                    HStack(spacing: 12) {
                                        ForEach(group, id: \.id) { act in
                                            ActivityBlockView(activity: act)
                                                .shadow(radius: 4)
                                        }
                                    }
                                }
                            }
                            .padding()
                            ArrowOverlay()
                        }
                        .coordinateSpace(name: "ChartSpace")

                        Divider().padding(.vertical)

                        // 🗓 Prompt and Date Picker
                        VStack(spacing: 12) {
                            Text("Choose a start date:")
                                .font(.headline)

                            if showDatePicker {
                                DatePicker(
                                    "Project Start Date",
                                    selection: $projectStartDate,
                                    displayedComponents: [.date]
                                )
                                .datePickerStyle(.graphical)
                                .padding(.horizontal)
                            } else {
                                Button(action: {
                                    withAnimation {
                                        showDatePicker = true
                                    }
                                }) {
                                    Text("Select Start Date")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 16, weight: .medium))
                                }
                            }
                        }
                        .padding()
                    }
                }

                Spacer()

                Button(action: {
                    navigateToCalendar = true
                }) {
                    Text("View Calendar")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding([.horizontal, .bottom])
                }

                NavigationLink(
                    destination: CalendarView(startDate: projectStartDate, activities: activities),
                    isActive: $navigateToCalendar
                ) {
                    EmptyView()
                }
            }
            .background(Color.white.opacity(0.95))
            .navigationTitle("Graphical Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
        }
    }
    
}

struct ActivityBlockView: View {
    var activity: Activity
    @EnvironmentObject var activityPositions: ActivityPositions

    var body: some View {
        Rectangle()
            .fill(activity.totalFloat == 0 ? Color.red : Color.blue)
            .frame(width: 100, height: 140)
            .overlay(
                VStack(spacing: 4) {
                    Text(activity.name)
                        .font(.custom("HelveticaNeue-Bold", size: 14))
                    Text("Du: \(activity.duration)")
                        .font(.custom("HelveticaNeue", size: 12))
                    Text("ES:\(activity.earlyStart) EF:\(activity.earlyFinish)")
                        .font(.custom("HelveticaNeue", size: 10))
                    Text("LS:\(activity.lateStart) LF:\(activity.lateFinish)")
                        .font(.custom("HelveticaNeue", size: 10))
                }
                .foregroundColor(.white)
                .padding(6)
            )
            .background(GeometryReader { geo in
                Color.clear.onAppear {
                    let frame = geo.frame(in: .named("ChartSpace"))
                    activityPositions.updatePosition(
                        for: activity.id,
                        top: CGPoint(x: frame.midX, y: frame.minY),
                        bottom: CGPoint(x: frame.midX, y: frame.maxY)
                    )
                }
            })
            .cornerRadius(8)
    }
}

struct ArrowOverlay: View {
    @EnvironmentObject var activityPositions: ActivityPositions
    @Query(sort: [
        SortDescriptor(\Activity.id),
        SortDescriptor(\Activity.name)
    ]) var activities: [Activity]

    var body: some View {
        Canvas { context, size in
            for act in activities {
                guard let from = activityPositions.position(for: act.id)?.bottom else { continue }
                for succ in act.successors {
                    guard let to = activityPositions.position(for: succ.id)?.top else { continue }
                    drawArrow(from: from, to: to, in: context)
                }
            }
        }
    }

    func drawArrow(from start: CGPoint, to end: CGPoint, in context: GraphicsContext) {
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        context.stroke(path, with: .color(.black), lineWidth: 2)

        let len: CGFloat = 12, angle: CGFloat = .pi / 6
        let theta = atan2(end.y - start.y, end.x - start.x)
        let p1 = CGPoint(x: end.x - len*cos(theta+angle), y: end.y - len*sin(theta+angle))
        let p2 = CGPoint(x: end.x - len*cos(theta-angle), y: end.y - len*sin(theta-angle))

        var head = Path()
        head.move(to: end)
        head.addLine(to: p1)
        head.addLine(to: p2)
        head.closeSubpath()
        context.fill(head, with: .color(.black))
    }
}

class ActivityPositions: ObservableObject {
    @Published var positions: [Int: (top: CGPoint, bottom: CGPoint)] = [:]

    func updatePosition(for id: Int, top: CGPoint, bottom: CGPoint) {
        positions[id] = (top, bottom)
    }

    func position(for id: Int) -> (top: CGPoint, bottom: CGPoint)? {
        positions[id]
    }
}
