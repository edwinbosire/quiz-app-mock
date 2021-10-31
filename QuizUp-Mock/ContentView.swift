//
//  ContentView.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 29/10/2021.
//

import SwiftUI

let popularTopics: [(title: String, icon: String)] = [("Geography", "globe"),
													  ("Riddles","clock.arrow.2.circlepath"),
													  ("World Capitals","mappin.and.ellipse"),
													  ("Basic Maths","function"),
													  ("Chemistry","metronome"),
													  ("Movies","video"),
													  ("Human body","figure.walk"),
													  ("Physics", "number"),
													  ("Biology", "waveform.path.ecg")]

let backgroundGradientColors = Gradient(colors: [Color(hex:"484848"), Color(hex:"242424")])
let backgroundGradient = LinearGradient(gradient: backgroundGradientColors,
										startPoint: .topTrailing,
										endPoint: .bottomLeading)

struct ContentView: View {
	let tabbarHeight = 82.0
	var body: some View {
		GeometryReader { geometry in
			VStack {
				ScrollView {
					VStack(spacing: 5) {
						MenuBar()
							.foregroundColor(.white)
							.padding()
							.padding(.top, 25)

						Highlights()

						RecentlyPlayed()

						PopularTopics(topics: popularTopics)

						Spacer()
					}
				}
				.frame(height: geometry.size.height - tabbarHeight)

				CustomTabbar()
					.frame(width: geometry.size.width, height: tabbarHeight)
			}

		}
		.edgesIgnoringSafeArea([.top, .bottom])
		.background(backgroundGradient)
		.preferredColorScheme(.dark)

	}
}

struct CustomTabbar: View {
	var body: some View {
		GeometryReader { geometry in
			HStack(alignment: .center) {
				TabbarIcon(width: geometry.size.width/5,
						   height: geometry.size.height/4,
						   systemIconName: "house",
						   tabName: "Home")

				TabbarIcon(width: geometry.size.width/5,
						   height: geometry.size.height/4,
						   systemIconName: "heart",
						   tabName: "Liked")

//				TabbarIcon(width: geometry.size.width/5,
//						   height: geometry.size.height/4,
//						   systemIconName: "plus",
//						   tabName: "Add")

				ZStack {
					Circle()
						.foregroundColor(Color(hex:"242424"))
						.frame(width: geometry.size.width/6, height: geometry.size.height)

					Image(systemName: "plus.circle.fill")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: geometry.size.width/6 - 8, height: geometry.size.height - 8)
						.foregroundColor(Color.purple)

				}
				.offset(y: -geometry.size.height/2)
				TabbarIcon(width: geometry.size.width/5,
						   height: geometry.size.height/4,
						   systemIconName: "waveform",
						   tabName: "Records")

				TabbarIcon(width: geometry.size.width/5,
						   height: geometry.size.height/4,
						   systemIconName: "person.crop.circle",
						   tabName: "Account")

			}
		}
		.background(Color(hex: "535353"))
		.edgesIgnoringSafeArea(.bottom)
	}
}

struct TabbarIcon: View {
	let width: CGFloat
	let height: CGFloat
	let systemIconName: String
	let tabName: String

	var body: some View {
		VStack {
			Image(systemName: systemIconName)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: width, height: height)
				.padding(.top, 10)
			Text(tabName)
				.font(.footnote)
			Spacer()
		}
		.padding(.horizontal, -4)
	}
}

struct MenuBar: View {
	var body: some View {
		HStack {
			Text("QuizUp")
				.font(.headline)
				.fontWeight(.heavy)
				.bold()
			Spacer()
			Image(systemName: "person.crop.circle")
				.font(.body)
			Image(systemName: "envelope.circle")
				.font(.body)
		}
	}
}

struct Highlights: View {
	var body: some View {
		VStack {
			TabView {
				VStack {
					Rectangle()
						.fill(.blue)
						.cornerRadius(20)
				}
				.padding()
				.padding(.bottom, 25)

				VStack {
					Rectangle()
						.fill(.green)
						.cornerRadius(20)
				}
				.padding()
				.padding(.bottom, 25)

				VStack {
					Rectangle()
						.fill(.red)
						.cornerRadius(20)
				}
				.padding()
				.padding(.bottom, 25)

			}
			.tabViewStyle(PageTabViewStyle())
			.frame(height: 300)
			.background(.clear)
		}
	}
}

struct RecentlyPlayed: View {
	var body: some View {
		VStack {
			HStack {
				Text("RECENTLY PLAYED")
					.font(.headline)
					.fontWeight(.heavy)
					.foregroundColor(Color(hex: "555555"))
				Spacer()
			}
			.padding(.leading, 10)

			ScrollView(.horizontal, showsIndicators: false) {
				HStack {
					VStack(spacing: 5) {
						RadialIcon(icon: "bonjour", progress: 75)
							.frame(width: 90, height: 90)
						Text("science")
							.font(.headline)
							.fontWeight(.bold)
							.foregroundColor(.white)
					}

					VStack(spacing: 5) {
						RadialIcon(icon: "bolt", highlight: Color.purple, progress: 45)
							.frame(width: 90, height: 90)
						Text("fiction")
							.font(.headline)
							.fontWeight(.bold)
							.foregroundColor(.white)
					}

					VStack(spacing: 5) {
						RadialIcon(icon: "waveform.path.ecg", highlight: Color.blue, progress: 10)
							.frame(width: 90, height: 90)
						Text("chemistry")
							.font(.headline)
							.fontWeight(.bold)
							.foregroundColor(.white)
					}

					VStack(spacing: 5) {
						RadialIcon(icon: "clock.arrow.circlepath", highlight: Color.red, progress: 30)
							.frame(width: 90, height: 90)
						Text("history")
							.font(.headline)
							.fontWeight(.bold)
							.foregroundColor(.white)
					}

					VStack(spacing: 5) {
						RadialIcon(icon: "desktopcomputer", highlight: Color.blue, progress: 10)
							.frame(width: 90, height: 90)
						Text("computing")
							.font(.headline)
							.fontWeight(.bold)
							.foregroundColor(.white)
					}

				}
				.padding(.leading, 16)
			}
		}
	}
}

struct RadialIcon: View {
	let icon: String
	var highlight: Color = .green
	var progress: Double = 0.0
	var body: some View {
		GeometryReader { geo in
			let padding = 0.8444
			let width = geo.size.width * 0.95
			let height = geo.size.height * 0.95

			ZStack {
				Circle()
					.fill(Color(hex: "535353"))
					.frame(width: width, height: height)

				Arc(startAngle: .degrees(0), endAngle: .degrees(progress*360/100), clockwise: true)
					.stroke(highlight, style: StrokeStyle(lineWidth:8, lineCap: .round, lineJoin: .round))
					.frame(width: width * 0.92, height: height * 0.92)

				Circle()
					.fill(Color(white: 0.02))
					.frame(width: width * padding, height: height * padding)

				Circle()
					.fill(Color(hex: "535353"))
					.frame(width: width * 0.78, height: height * 0.78)

				Image(systemName: icon)
					.font(.system(size: geo.size.width * 76/180))
					.minimumScaleFactor(0.1)
					.foregroundColor(highlight)

			}

		}
		.padding(5)
	}
}

struct Arc: Shape {
	var startAngle: Angle
	var endAngle: Angle
	var clockwise: Bool

	func path(in rect: CGRect) -> Path {
		let rotationAdjustment = Angle.degrees(90)
		let modifiedStart = startAngle - rotationAdjustment
		let modifiedEnd = endAngle - rotationAdjustment

		var path = Path()
		path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: modifiedStart, endAngle: modifiedEnd, clockwise: !clockwise)

		return path
	}
}

struct PopularTopics: View {
	let topics: [(title: String, icon: String)]
	var body: some View {
		VStack(spacing: 5) {
			HStack {
				Text("POPULAR TOPICS")
					.font(.headline)
					.fontWeight(.heavy)
					.foregroundColor(Color(hex: "555555"))
				Spacer()
			}

			let gridItems = [GridItem(.fixed(75), spacing: 10),
							 GridItem(.fixed(75), spacing: 10)]

			ScrollView(.horizontal, showsIndicators: false) {
				LazyHGrid(rows: gridItems, spacing: 10) {
					ForEach(0..<topics.count) { idx in

						VStack {
							Image(systemName: topics[idx].icon)
								.resizable()
								.aspectRatio(contentMode: .fit)
								.frame(width:40, height: 40)
								.padding(.top, 10)

							Text(topics[idx].title)
								.font(.system(size: 10))
								.fontWeight(.light)

						}
						.frame(width: 75, height: 75)
						.background(Color(hex: "434343"))
						.foregroundColor(Color(hex:"C4C4C4"))
						.cornerRadius(10)

					}
				}
			}
			.frame(height: 180)
		}
		.padding()
		.padding(.top, 0)

		Spacer()
	}

}


struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
