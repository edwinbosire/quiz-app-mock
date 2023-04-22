//
//  MonitizationView.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 19/03/2023.
//

import SwiftUI

struct MonitizationView: View {
	@Environment(\.dismiss) var dismiss

	@Binding var route: Route
	var body: some View {
		VStack {
			header()
//			GeometryReader { proxy in
//				HStack(spacing: 0) {
//					InAppPurchasePriceCard(title: "Weekly", subTitle: "", price: "£2.99")
//						.frame(width: proxy.size.width / 3)
//					InAppPurchasePriceCard(title: "Monthly", subTitle: "", price: "£4.99")
//						.frame(width: proxy.size.width / 3)
//					InAppPurchasePriceCard(title: "3 Months", subTitle: "", price: "£9.99")
//						.frame(width: proxy.size.width / 3)
//				}
//				.frame(height: 150)
//				.padding(.top, 40)
//			}
//			.frame(height: 200)


//			Spacer()
			VStack {
				Button(action: {}) {
					Text("£3.99 unlimitted access")
				}
				.padding()
				.foregroundColor(.white)
				.frame(maxWidth: .infinity)
				.background(RoundedRectangle(cornerRadius: 20)
					.fill(.blue)
					.padding(.horizontal)
				)

				Button(action: {}) {
					Text("Restore")
				}
				.padding()
				.frame(maxWidth: .infinity)
				.background(RoundedRectangle(cornerRadius: 20)
					.stroke(Color.blue)
					.padding(.horizontal)
				)

			}
			.padding(.top, 40)
//			Spacer()

			VStack(alignment: .leading, spacing: 10) {
				Text("You can cancel your subscription anytime through your Apple Store account settings, or it will automattivally renew.")

				Text("This must be done 24 hours before any subscription period to avaoid being charged.")

				Text("By continuing, you agree to our EULA and Privacy Policy")
			}
			.font(.footnote)
			.foregroundStyle(.secondary)
			.padding(.horizontal)
			.padding(.vertical)
			Spacer()

		}
		.background(Color("Background"))
	}

	func header() -> some View {
		VStack {
			ZStack(alignment: .center) {
				Text("Go Pro!")
					.font(.largeTitle)
					.bold()


				HStack(alignment: .firstTextBaseline) {
					Spacer()
					Button {
						route = .mainMenu
						dismiss()
					} label: {
						Image(systemName: "xmark")
							.font(.largeTitle)
					}
					.padding()
				}
			}
			.padding(.bottom, 20)



			VStack(alignment: .leading) {
				HStack {
					Image(systemName: "checkmark.seal.fill")
					Text("Unlock all exams")
				}

				HStack {
					Image(systemName: "checkmark.seal.fill")
					Text("Unlock all reading material")
				}

				HStack {
					Image(systemName: "checkmark.seal.fill")
					Text("Enable audio naration")
				}

				HStack {
					Image(systemName: "checkmark.seal.fill")
					Text("Receive content updates")
				}

				HStack {
					Image(systemName: "checkmark.seal.fill")
					Text("Remove adds")
				}
			}
		}
		.padding(.bottom, 30)
		.foregroundColor(Color.titleText)
		.background(
			Color.defaultBackground
				.clipShape(RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 50))
				.shadow(color: .black.opacity(0.06), radius: 9, x:0.0, y: 8.0)
		)

	}
}

struct MonitizationView_Previews: PreviewProvider {
    static var previews: some View {
		MonitizationView(route: .constant(.monetization))
    }
}


struct InAppPurchasePriceCard: View {
	let title: String
	let subTitle: String
	let price: String
	var body: some View {
		VStack(alignment: .center) {
			Text(title)
				.font(.headline)
				.foregroundColor(Color.paletteBlueDark)
				.padding(.top, 20)
				.foregroundStyle(.secondary)

			Spacer()

			Text(subTitle)
				.font(.body)
				.padding(.top, 10)
				.foregroundStyle(.secondary)
				.foregroundColor(Color.paletteBlueDark)
				.multilineTextAlignment(.leading)

			Text(price)
				.font(.largeTitle)
				.bold()
		}
		.frame(height: 120)
		.padding()
		.background(RoundedRectangle(cornerRadius: 10)
			.fill(Color.rowBackground)
			.shadow(color: .black.opacity(0.09), radius: 4, y: 2))

	}
}
