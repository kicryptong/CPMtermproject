// MonthlyCostView.swift

import SwiftUI

struct MonthlyCostView: View {
    var monthlyCosts: [(month: Int, subtotal: Double, markup: Double)]
    var monthlyTotalBilled: [Int: Double]
    @State private var paymentsReceived: [Int: String] = [:]
    @State private var showChart = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            List(monthlyCosts, id: \.month) { cost in
                VStack(alignment: .leading) {
                    Text("Month \(cost.month)")
                        .font(.headline)
                    // MARK: - Currency Change
                    Text("Direct Cost : \(cost.subtotal, specifier: "%.2f") $")
                    Text("Markup : \(cost.markup, specifier: "%.2f") $")
                    
                    if let billed = monthlyTotalBilled[cost.month] {
                        // MARK: - Currency Change
                        Text("Total Billed: \(billed, specifier: "%.2f") $")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        TextField("Payment received for month \(cost.month)", text: Binding(
                            get: { paymentsReceived[cost.month] ?? "" },
                            set: { paymentsReceived[cost.month] = $0 }
                        ))
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        let received = Double(paymentsReceived[cost.month] ?? "") ?? 0
                        let balance = received - billed
                        
                        // MARK: - Currency Change
                        Text("Balance: \(balance, specifier: "%.2f") $")
                            .foregroundColor(balance >= 0 ? .green : .red)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.top, 2)
                    }
                }
                .padding(.vertical, 5)
            }

            Button {
                showChart = true
            } label: {
                Label("See the graph", systemImage: "chart.bar.fill")
                    .font(.headline)
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
            }
            .padding()
            .sheet(isPresented: $showChart) {
                MonthlyChartView(
                    monthlyCosts: monthlyCosts,
                    paymentsReceived: paymentsReceived
                )
            }
        }
        .navigationTitle("Monthly Cost")
        // .toolbar 블록 전체를 삭제하여 중복된 뒤로가기 버튼을 제거합니다.
    }
}
