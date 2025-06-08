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
                    Text("Direct Cost : \(cost.subtotal, specifier: "%.2f") €")
                    Text("Markup : \(cost.markup, specifier: "%.2f") €")
                    
                    if let billed = monthlyTotalBilled[cost.month] {
                        Text("Total Billed: \(billed, specifier: "%.2f") €")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        // Payment input field
                        TextField("Payment received month \(cost.month)", text: Binding(
                            get: {
                                paymentsReceived[cost.month] ?? ""
                            },
                            set: {
                                paymentsReceived[cost.month] = $0
                            }
                        ))
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        // Calculate and display balance
                        let received = Double(paymentsReceived[cost.month] ?? "") ?? 0
                        let balance = received - billed
                        
                        Text("Balance: \(balance, specifier: "%.2f") €")
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

