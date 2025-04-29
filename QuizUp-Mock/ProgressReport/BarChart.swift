//
//  BarChart.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 29/04/2025.
//

import Charts
import SwiftUI

struct BarCharts: View {
	let results: [ExamResultViewModel]
	let linearGradient = LinearGradient(gradient: Gradient(colors: [Color.accentColor.opacity(0.4), Color.accentColor.opacity(0)]), startPoint: .top,endPoint: .bottom)

	var body: some View {
		Chart {
			ForEach(resultsSortedByDate.indices, id: \.self) { index in
				let result = resultsSortedByDate[index]
				LineMark(
					x: .value("Exam", result.exam.dateAttempted),
					y: .value("Score", result.exam.scorePercentage)
				)
				.interpolationMethod(.cardinal)
			}

			ForEach(resultsSortedByDate.indices, id: \.self) { index in
				let result = resultsSortedByDate[index]
				AreaMark(
					x: .value("Exam", result.exam.dateAttempted),
					y: .value("Score", result.exam.scorePercentage)
				)
				.interpolationMethod(.cardinal)
				.foregroundStyle(linearGradient)
			}

			RuleMark(y: .value("Pass Mark", 75))
				.foregroundStyle(Color.pink.opacity(0.2))
				.annotation(position: .bottom,
							alignment: .bottomLeading) {
					Text("Pass mark is 75%")
						.font(.footnote)
						.foregroundStyle(.secondary)
				}

		}
//		.chartYAxisLabel("Score (%)", position: .trailing, alignment: .bottom)
//		.chartXScale(domain: 0...results.count-1)
		.chartYScale(domain: 0...100)
		.chartXAxis(content: {
			AxisMarks(values: .automatic(desiredCount: results.count+2)) {
				AxisTick()
				AxisGridLine()
				AxisValueLabel(format: .dateTime.month().day(), centered: false, anchor: .top)
			}
			// Add forced marks for first and last explicitly
			AxisMarks(values: [results.first?.exam.dateAttempted].compactMap { $0 }) { value in
				AxisTick()
				AxisGridLine()

				if let _ = value.as(Date.self) {
					AxisValueLabel(format: .dateTime.month().day(), centered: false, anchor: .topLeading)
				}
			}

			AxisMarks(values: [results.last?.exam.dateAttempted].compactMap { $0 }) { value in
				AxisTick()
				AxisGridLine()

				if let _ = value.as(Date.self) {
					AxisValueLabel(format: .dateTime.month().day(), centered: false, anchor: .topTrailing)
				}
			}

		})
		.chartYAxis(content: {
//			AxisMarks(preset: .aligned, position: .trailing, values: .automatic(desiredCount: 10), stroke: .init(lineWidth: 1))
			AxisMarks(format: Decimal.FormatStyle.Percent.percent.scale(1), position: .trailing, values: .automatic(desiredCount: 10))
		})
		.foregroundStyle(.linearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom))
		.aspectRatio(1, contentMode: .fit)
		.padding()
	}

	var resultsSortedByDate: [ExamResultViewModel] {
		results.sorted { $0.formattedDate < $1.formattedDate }
	}
}
