//
//  ContentView.swift
//  BrowseWheelDemo
//
//  Created by Bill Panagiotopoulos on 29/2/24.
//

import SwiftUI
import BrowseWheel

struct ContentView: View {
    @State private var items = createItems()
    @State private var spacing = -80.0
    @State private var padding = 50.0
    @State private var minScale = 0.6
    @State private var page = 0

    var body: some View {
        VStack(spacing: 40) {
            BrowseWheel(
                items: items,
                page: $page,
                spacing: $spacing,
                padding: $padding,
                minScale: $minScale) { item in
                    ZStack {
                        Rectangle()
                            .foregroundColor(item.color)
                        Text(item.title)
                    }
                    .cornerRadius(10)
                    .shadow(radius: 2, x: 1.5, y: 1.5)
                }
                .frame(height: 150)

            VStack {
                Divider()

                Text("Item: \(page+1)")

                HStack {
                    Button("Previous") {
                        page -= 1
                    }
                    Button("Next") {
                        page += 1
                    }
                }
                Divider()

                Text("Spacing: \(spacing)")
                Slider(value: $spacing, in: -200...50)

                Text("Padding: \(padding)")
                Slider(value: $padding, in: -100...100)

                Text("Min Scale: \(minScale)")
                Slider(value: $minScale, in: 0...1)
            }
        }
    }
}

extension ContentView {
    static func createItems() -> [Item] {
        [
            Item(id: UUID(), title: "Item 1", color: .green),
            Item(id: UUID(), title: "Item 2", color: .blue),
            Item(id: UUID(), title: "Item 3", color: .red),
            Item(id: UUID(), title: "Item 4", color: .yellow),
            Item(id: UUID(), title: "Item 5", color: .gray),
            Item(id: UUID(), title: "Item 6", color: .yellow)
        ]
    }
}


#Preview {
    ContentView()
}
