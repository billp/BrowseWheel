// ContentView.swift
//
// Copyright © 2024 Vassilis Panagiotopoulos. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in the
// Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
// and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies
// or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FIESS FOR A PARTICULAR
// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
// FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
