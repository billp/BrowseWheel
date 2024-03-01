// ChangeObserver.swift
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

struct ValueChangeObserver<Content: View, ObservedValue: Equatable>: View {
    private let content: () -> Content
    private let observedValue: ObservedValue
    private let onValueChange: (ObservedValue) -> Void

    @State private var lastObservedValue: ObservedValue

    init(observedValue: ObservedValue, onValueChange: @escaping (ObservedValue) -> Void, @ViewBuilder content: @escaping () -> Content) {
        self._lastObservedValue = State(initialValue: observedValue)
        self.observedValue = observedValue
        self.onValueChange = onValueChange
        self.content = content
    }

    var body: some View {
        if true {
            DispatchQueue.main.async {
                checkForChanges()
            }
            return self.content()
        }
    }

    private func checkForChanges() {
        if lastObservedValue != observedValue {
            lastObservedValue = observedValue
            onValueChange(observedValue)
        }
    }
}

extension View {
    func onValueChange<ObservedValue: Equatable>(
        of observedValue: ObservedValue,
        perform action: @escaping (_ newValue: ObservedValue) -> Void) -> some View {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                return self.onChange(of: observedValue,
                                     perform: action)
            } else {
                return ValueChangeObserver(observedValue: observedValue, 
                                           onValueChange: action) {
                    self
                }
            }

    }
}
