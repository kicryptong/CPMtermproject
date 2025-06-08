//
//  DetailPredictionView.swift
//  CPM_Graphic
//
//  Created by snlcom on 6/2/25.
//

import SwiftUI

struct DetailPredictionView: View {
    let prediction: DailyWorkPrediction

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
                    Text(prediction.isWorkable ? "공사 가능" : "공사 중단 고려")
                        .font(.headline)
                        .foregroundColor(prediction.isWorkable ? .green : .red)
                }

                Divider()

                Text("사유")
                    .font(.headline)

                ForEach(prediction.reasons, id: \.self) { reason in
                    Text("• \(reason)")
                        .font(.body)
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("예보 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
        }
    }
}
