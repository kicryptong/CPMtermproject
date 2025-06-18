import SwiftUI
import Charts

struct MonthlyChartView: View {
    var monthlyCosts: [(month: Int, subtotal: Double, markup: Double)]
    var paymentsReceived: [Int: String]  // ⬅️ New input
    @Environment(\.dismiss) var dismiss

    struct MonthlyCost: Identifiable {
        let id = UUID()
        let month: Int
        let type: String
        let value: Double
    }

    var chartData: [MonthlyCost] {
        var data: [MonthlyCost] = []
        for cost in monthlyCosts {
            data.append(MonthlyCost(month: cost.month, type: "Subtotal", value: cost.subtotal))
            data.append(MonthlyCost(month: cost.month, type: "Markup", value: cost.markup))
        }
        return data
    }

    var paymentPoints: [(month: Int, value: Double)] {
        monthlyCosts.compactMap { cost in
            if let str = paymentsReceived[cost.month], let val = Double(str) {
                return (month: cost.month, value: val)
            }
            return nil
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                Chart {
                    // Bars
                    ForEach(chartData) { entry in
                        BarMark(
                            x: .value("Month", "M\(entry.month)"),
                            y: .value("Value", entry.value)
                        )
                        .foregroundStyle(by: .value("Type", entry.type))
                    }

                    // Payments received (line with circle points)
                    ForEach(paymentPoints, id: \.month) { point in
                        LineMark(
                            x: .value("Month", "M\(point.month)"),
                            y: .value("Payment Received", point.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.pink)
                        .lineStyle(StrokeStyle(lineWidth: 2))

                        PointMark(
                            x: .value("Month", "M\(point.month)"),
                            y: .value("Payment Received", point.value)
                        )
                        .foregroundStyle(.pink)
                        .symbolSize(60)
                    }
                }
                
                .chartForegroundStyleScale([
                    "Subtotal": .blue,
                    "Markup": .green,
                    "Payment Received": .pink
                ])
                .chartLegend(position: .bottom)
                
                .frame(height: 300)
                .padding()
            }
            .navigationTitle("Cost Graph")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                    }
                }
            }
        }
    }
}

