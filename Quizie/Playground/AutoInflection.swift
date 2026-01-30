//
//  AutoInflection.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 09/03/2023.
//

import SwiftUI

struct AutoInflection: View {
	@State var count = 1
    var body: some View {
		VStack(alignment: .leading) {
			Text("Hello Edwin")
				.font(.title)
				.bold()
				.foregroundStyle(.primary)
			Text("^[There are \(count) people](inflect: true) in the queue")
				.font(.caption2)
				.foregroundStyle(.secondary)

			HStack {
				Button(action: { count += 1}) {
					Text("+")
						.foregroundColor(.green)
				}
				.buttonStyle(.bordered)
				.clipShape(Circle())


				Button(action: { count -= 1}) {
					Text("-")
						.foregroundColor(.red)
				}
				.buttonStyle(.bordered)
				.clipShape(Circle())

			}

		}
    }
}

struct AutoInflection_Previews: PreviewProvider {
    static var previews: some View {
        AutoInflection()
    }
}
