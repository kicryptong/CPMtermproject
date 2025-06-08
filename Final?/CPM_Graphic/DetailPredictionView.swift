// DetailPredictionView.swift

import SwiftUI

struct DetailPredictionView: View {
    let prediction: DailyWorkPrediction
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text(prediction.date.formatted(date: .long, time: .omitted))
                    .font(.title2)
                    .bold()

                HStack {
                    Image(systemName: prediction.isWorkable ? "checkmark.circle.fill" : "xmark.octagon.fill")
                        .foregroundColor(prediction.isWorkable ? .green : .red)
                        .font(.title2)
                    Text(prediction.isWorkable ? "Workable" : "Consider Halting Work")
                        .font(.headline)
                        .foregroundColor(prediction.isWorkable ? .green : .red)
                }

                Divider()

                Text("Reasons")
                    .font(.headline)

                if prediction.reasons.isEmpty {
                    Text("• Favorable conditions.")
                        .font(.body)
                        .foregroundColor(.gray)
                } else {
                    ForEach(prediction.reasons, id: \.self) { reason in
                        Text("• \(reason)")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Forecast Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
