// CarouselView.swift
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
import Combine

/// A Carousel View that displays a scrollable, horizontal list of items.
public struct BrowseWheel<Content: View, Item, ID: Hashable>: View {
    var items: [Item]
    let content: (Item) -> Content
    let id: KeyPath<Item, ID>

    @State private var offsetX = 0.0
    @State private var lastX = 0.0
    @State private var width = 0.0
    @State private var currentPage: Int = 0
    @State private var proxy: GeometryProxy!

    @Binding private var publicPage: Int
    @Binding private var spacing: Double
    @Binding private var padding: Double
    @Binding private var minScale: Double
    @Binding private var itemsOffset: Double

    /// Initializes a carousel view.
    ///
    /// Configures a carousel with dynamic content and customizable properties,
    /// including item spacing, padding, and scale adjustments.
    ///
    /// - Parameters:
    ///   - items: Array of `Item` elements for the carousel.
    ///   - id: KeyPath to a unique identifier property for each item.
    ///   - page: Binding to the current page index.
    ///   - spacing: Space between items (default is `0.0`).
    ///   - padding: Padding around each item (default is `0.0`).
    ///   - minScale: Minimum scale for items (default is `1.0`).
    ///   - itemsOffset: The offset of the items (default is `0` = centered).
    ///   - content: Closure returning a view for each item.
    ///
    /// This initializer allows observing and controlling the carousel's
    /// visible page via `page`. It supports custom views for each item,
    /// defined by `content`.
    ///
    /// Example:
    /// ```
    /// BrowseWheel(items: myItems, id: \.id, page: $currentPage) { item in
    ///     MyItemView(item: item)
    /// }
    /// ```
    public init(
        items: [Item],
        id: KeyPath<Item, ID>,
        page: Binding<Int>,
        spacing: Binding<Double>,
        padding: Binding<Double>,
        minScale: Binding<Double>,
        itemsOffset: Binding<Double>,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.id = id
        self.items = items
        self._publicPage = page
        self._minScale = minScale
        self._spacing = spacing
        self._padding = padding
        self._itemsOffset = itemsOffset
        self.content = content
    }

    public var body: some View {
        VStack {
            GeometryReader { reader in
                HStack(spacing: spacing) {
                    ForEach(items, id: id) { item in
                        content(item)
                            .frame(width: reader.size.width - padding * 2)
                            .scaleEffect(calculateScale(for: item, reader: reader))
                            .contentShape(Rectangle())
                            .padding(.leading, padding)
                            .zIndex(currentPage == itemIndex(item) ? 1 : -1)
                    }
                }
                .animation(.spring(duration: 0.28), value: offsetX)
                .offset(x: offsetX + currentPagePadding + itemsOffset)
                .gesture(dragGesture(reader))
                .onValueChange(of: self.publicPage) { val in
                    scroll(to: val)
                }
                .onAppear {
                    print(self.spacing)
                    proxy = reader
                    self.scroll(to: self.publicPage)
                }
            }
        }
    }

    struct BindingObserver: View {
        @Binding var value: Int
        let action: (Int) -> Void

        var body: some View {
            Color.clear
                .onAppear { self.action(self.value) }
        }
    }
}

extension BrowseWheel where Item: Identifiable, Item.ID == ID {
    /// Initializes a carousel view.
    ///
    /// Configures a carousel with dynamic content and customizable properties,
    /// including item spacing, padding, and scale adjustments.
    ///
    /// - Parameters:
    ///   - items: Array of `Item` elements for the carousel.
    ///   - page: Binding to the current page index.
    ///   - spacing: Space between items (default is `0.0`).
    ///   - padding: Padding around each item (default is `0.0`).
    ///   - minScale: Minimum scale for items (default is `1.0`).
    ///   - itemsOffset: The offset of the items (default is `0` = centered).
    ///   - content: Closure returning a view for each item.
    ///
    /// This initializer allows observing and controlling the carousel's
    /// visible page via `page`. It supports custom views for each item,
    /// defined by `content`.
    ///
    /// Example:
    /// ```
    /// CarouselView(items: myItems, id: \.id, page: $currentPage) { item in
    ///     MyItemView(item: item)
    /// }
    /// ```
    public init(
        items: [Item],
        page: Binding<Int>,
        spacing: Binding<Double>,
        padding: Binding<Double>,
        minScale: Binding<Double>,
        itemsOffset: Binding<Double>,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.id = \Item.id
        self.content = content
        self._publicPage = page
        self._spacing = spacing
        self._padding = padding
        self._itemsOffset = itemsOffset
        self._minScale = minScale
    }
}

extension BrowseWheel {
    private func dragGesture(_ reader: GeometryProxy) -> some Gesture {
        let drag = DragGesture(minimumDistance: 30)
            .onChanged(onGestureChanged)
            .onEnded(onGestureEnded)

        let pinch = MagnificationGesture(minimumScaleDelta: 0.0)
            .onChanged({ delta in
                scroll(to: currentPage)
            })
            .onEnded({ delta in
                scroll(to: currentPage)
            })

        let rotation = RotationGesture(minimumAngleDelta: Angle(degrees: 0.0))
            .onChanged({ delta in
                scroll(to: currentPage)
            })
            .onEnded({ delta in
                scroll(to: currentPage)
            })

        let longPress = LongPressGesture(minimumDuration: 0.0, maximumDistance: 0.0)
            .onChanged({ _ in
                scroll(to: currentPage)
            })
            .onEnded({ delta in
                scroll(to: currentPage)
            })


        let combinedGesture = drag
            .simultaneously(with: pinch)
            .simultaneously(with: rotation)
            .exclusively(before: longPress)

        return combinedGesture
    }

    private func onGestureChanged(_ value: DragGesture.Value) {
        offsetX = lastX + value.translation.width
    }

    private func onGestureEnded(_ value: DragGesture.Value) {
        width = proxy.size.width

        var newPage = currentPage
        if isScrollingOutOfBoundsLeft {
            newPage = 0
        } else if isScrollingOutOfBoundsRight {
            newPage = items.count - 1
        } else if shouldChangePageOnLeft(value) {
            newPage -= 1
        } else if shouldChangePageOnRight(value) {
            newPage += 1
        }

        scroll(to: newPage)
        lastX = offsetX
    }

    private func calculateScale(for item: Item, reader: GeometryProxy) -> Double {
        let itemPage = itemIndex(item)
        let offsetPercentage = offsetX / reader.size.width
        let nextPage = calculateNextPage()
        let currentScale = abs(abs(Double(nextPage)) - abs(offsetPercentage))

        if nextPage == currentPage {
            return itemPage == nextPage ? 1 : minScale
        }
        if itemPage == currentPage {
            return min(max(currentScale, minScale), 1)
        }
        if isNextPageItem(item) {
            return min(1, (1 - currentScale + minScale) * 0.98)
        }

        return minScale
    }

    private var isScrollingLeft: Bool {
        offsetX > lastX
    }

    private var isScrollingRight: Bool {
        offsetX < lastX
    }

    private var isScrollingOutOfBoundsLeft: Bool {
        currentPage == 0 && isScrollingLeft
    }

    private var isScrollingOutOfBoundsRight: Bool {
        offsetX < -width * Double(items.count - 1)
    }

    private var currentPagePadding: Double {
        if currentPage ==  items.count - 1 || currentPage > 0 {
            return padding * Double(currentPage) + abs(spacing) * Double(currentPage)
        }
        return 0
    }

    func calculateNextPage() -> Int {
        switch (isScrollingLeft, isScrollingRight) {
        case (true, _):
            return currentPage - 1
        case (_, true):
            return currentPage + 1
        default:
            return currentPage
        }
    }

    private func shouldChangePageOnLeft(_ value: DragGesture.Value) -> Bool {
        value.predictedEndTranslation.width > width / 2.0
    }

    private func shouldChangePageOnRight(_ value: DragGesture.Value) -> Bool {
        value.predictedEndTranslation.width < -width / 2.0
    }

    private func itemIndex(_ item: Item) -> Int {
        guard let index = items
            .firstIndex(where: { $0[keyPath: id] == item[keyPath: id] }) else {
            return 0
        }

        return index
    }

    private func isNextPageItem(_ item: Item) -> Bool {
        let page = itemIndex(item)
        return isScrollingRight && page == currentPage + 1 ||
            isScrollingLeft && page == currentPage - 1
    }

    private func scroll(to page: Int) {
        guard page >= 0 && page < items.count else { return }
        
        offsetX = -Double(page) * proxy.size.width
        lastX = offsetX
        currentPage = page
        publicPage = page
    }
}

#Preview {
    struct Item: Identifiable {
        var id: UUID
        var title: String
        var color: Color
    }

    let items = [
        Item(id: UUID(), title: "Item 1", color: .green),
        Item(id: UUID(), title: "Item 2", color: .blue),
        Item(id: UUID(), title: "Item 3", color: .red),
        Item(id: UUID(), title: "Item 4", color: .yellow),
        Item(id: UUID(), title: "Item 5", color: .gray),
        Item(id: UUID(), title: "Item 6", color: .yellow)
    ]

    return VStack(spacing: 40) {
        BrowseWheel(
            items: items,
            page: .constant(0),
            spacing: .constant(-80),
            padding: .constant(50),
            minScale: .constant(0.6),
            itemsOffset: .constant(-50)) { item in
            ZStack {
                Rectangle()
                    .foregroundColor(item.color)
                Text(item.title)
            }
            .cornerRadius(10)
            .shadow(radius: 2, x: 1.5, y: 1.5)
        }
        .frame(height: 150)
    }
}
