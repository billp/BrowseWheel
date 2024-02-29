//
//  ChangeObserver.swift
//  BrowseWheel
//
//  Created by Bill Panagiotopoulos on 29/2/24.
//

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
