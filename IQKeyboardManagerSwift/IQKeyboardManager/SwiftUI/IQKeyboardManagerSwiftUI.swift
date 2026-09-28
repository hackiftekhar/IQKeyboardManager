//
//  IQKeyboardManagerSwiftUI.swift
//  https://github.com/hackiftekhar/IQKeyboardManager
//  Copyright (c) 2013-24 Iftekhar Qurashi.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import SwiftUI

#if canImport(SwiftUI)

/// Represents a registered focus item in a SwiftUI focus hierarchy with ordering and grouping metadata.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct IQFocusItem<Field: Hashable>: Equatable {
    public let field: Field
    public let order: Int
    public let group: AnyHashable?

    public init(field: Field, order: Int = 0, group: AnyHashable? = nil) {
        self.field = field
        self.order = order
        self.group = group
    }
}

/// Preference key used by `.iqFocus(...)` to collect field order and grouping metadata up the SwiftUI view hierarchy.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct IQFocusPreferenceKey<Field: Hashable>: PreferenceKey {
    public static var defaultValue: [IQFocusItem<Field>] { [] }

    public static func reduce(value: inout [IQFocusItem<Field>], nextValue: () -> [IQFocusItem<Field>]) {
        value.append(contentsOf: nextValue())
    }
}

/// View modifier that coordinates Previous, Next, and Done keyboard toolbar actions based on registered focus items.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct IQFocusScopeModifier<Field: Hashable>: ViewModifier {
    @Binding public var focus: Field?
    public var group: AnyHashable?

    @State private var registeredItems: [IQFocusItem<Field>] = []

    public init(focus: Binding<Field?>, group: AnyHashable? = nil) {
        self._focus = focus
        self.group = group
    }

    private var activeGroupItems: [IQFocusItem<Field>] {
        let items: [IQFocusItem<Field>]
        if let targetGroup = group {
            items = registeredItems.filter { $0.group == targetGroup }
        } else if let current = focus,
                  let currentItem = registeredItems.first(where: { $0.field == current }),
                  let currentGroup = currentItem.group {
            items = registeredItems.filter { $0.group == currentGroup }
        } else {
            items = registeredItems
        }

        // Deduplicate and sort ascending by order
        var seen = Set<Field>()
        var unique: [IQFocusItem<Field>] = []
        for item in items.sorted(by: { $0.order < $1.order }) where !seen.contains(item.field) {
            seen.insert(item.field)
            unique.append(item)
        }
        return unique
    }

    private var currentIndex: Int? {
        guard let current = focus else { return nil }
        return activeGroupItems.firstIndex(where: { $0.field == current })
    }

    private var canGoPrevious: Bool {
        guard let index = currentIndex else { return false }
        return index > 0
    }

    private var canGoNext: Bool {
        guard let index = currentIndex else { return false }
        return index < activeGroupItems.count - 1
    }

    private func moveToPrevious() {
        guard let index = currentIndex, index > 0 else { return }
        focus = activeGroupItems[index - 1].field
    }

    private func moveToNext() {
        guard let index = currentIndex, index < activeGroupItems.count - 1 else { return }
        focus = activeGroupItems[index + 1].field
    }

    public func body(content: Content) -> some View {
        content
            .onPreferenceChange(IQFocusPreferenceKey<Field>.self) { items in
                self.registeredItems = items
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button(action: moveToPrevious) {
                        Image(systemName: "chevron.up")
                    }
                    .disabled(!canGoPrevious)

                    Button(action: moveToNext) {
                        Image(systemName: "chevron.down")
                    }
                    .disabled(!canGoNext)

                    Spacer()

                    Button("Done") {
                        focus = nil
                    }
                }
            }
    }
}

/// View modifier that displays a keyboard toolbar for an explicit list of fields.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct IQExplicitFocusToolbarModifier<Field: Hashable>: ViewModifier {
    @Binding public var focus: Field?
    public let items: [IQFocusItem<Field>]

    public init(focus: Binding<Field?>, items: [IQFocusItem<Field>]) {
        self._focus = focus
        self.items = items
    }

    private var currentIndex: Int? {
        guard let current = focus else { return nil }
        return items.firstIndex(where: { $0.field == current })
    }

    private var canGoPrevious: Bool {
        guard let index = currentIndex else { return false }
        return index > 0
    }

    private var canGoNext: Bool {
        guard let index = currentIndex else { return false }
        return index < items.count - 1
    }

    private func moveToPrevious() {
        guard let index = currentIndex, index > 0 else { return }
        focus = items[index - 1].field
    }

    private func moveToNext() {
        guard let index = currentIndex, index < items.count - 1 else { return }
        focus = items[index + 1].field
    }

    public func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button(action: moveToPrevious) {
                        Image(systemName: "chevron.up")
                    }
                    .disabled(!canGoPrevious)

                    Button(action: moveToNext) {
                        Image(systemName: "chevron.down")
                    }
                    .disabled(!canGoNext)

                    Spacer()

                    Button("Done") {
                        focus = nil
                    }
                }
            }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension View {

    /**
     Registers a text field's identity, order number, and optional group for IQKeyboardManager focus management.

     - Parameters:
       - field: The unique field identifier.
       - order: The sequential sorting order for Previous/Next navigation. Lower values are navigated first.
       - group: An optional group identifier to scope navigation within a specific section or form.
     */
    func iqFocus<Field: Hashable>(field: Field, order: Int = 0, group: AnyHashable? = nil) -> some View {
        self.preference(key: IQFocusPreferenceKey<Field>.self,
                        value: [IQFocusItem(field: field, order: order, group: group)])
    }

    /**
     Enables an accessory toolbar on the keyboard with Previous, Next, and Done actions,
     automatically resolving order and group from `.iqFocus(...)` modifiers declared on child views.

     - Parameters:
       - focus: Binding to the currently focused field.
       - group: Optional group to restrict navigation to. If nil, automatically follows the active field's group.
     */
    func iqFocusScope<Field: Hashable>(focus: Binding<Field?>, group: AnyHashable? = nil) -> some View {
        self.modifier(IQFocusScopeModifier(focus: focus, group: group))
    }

    /**
     Enables an accessory toolbar on the keyboard bound to a `@FocusState`.
     */
    func iqFocusScope<Field: Hashable>(focus: FocusState<Field?>.Binding, group: AnyHashable? = nil) -> some View {
        self.iqFocusScope(focus: Binding(
            get: { focus.wrappedValue },
            set: { focus.wrappedValue = $0 }
        ), group: group)
    }

    /**
     Attaches an accessory toolbar with Previous / Next / Done for an explicit list of ordered fields.
     */
    func iqKeyboardToolbar<Field: Hashable>(focus: Binding<Field?>, fields: [Field]) -> some View {
        let items = fields.enumerated().map { IQFocusItem(field: $0.element, order: $0.offset) }
        return self.modifier(IQExplicitFocusToolbarModifier(focus: focus, items: items))
    }

    /**
     Attaches an accessory toolbar with Previous / Next / Done for an explicit list
     of ordered fields bound to a `@FocusState`.
     */
    func iqKeyboardToolbar<Field: Hashable>(focus: FocusState<Field?>.Binding, fields: [Field]) -> some View {
        self.iqKeyboardToolbar(focus: Binding(
            get: { focus.wrappedValue },
            set: { focus.wrappedValue = $0 }
        ), fields: fields)
    }

    /**
     Attaches an accessory toolbar with Previous / Next / Done for any `CaseIterable` enum.
     */
    func iqKeyboardToolbar<Field: Hashable & CaseIterable>(focus: Binding<Field?>) -> some View {
        let items = Array(Field.allCases).enumerated().map { IQFocusItem(field: $0.element, order: $0.offset) }
        return self.modifier(IQExplicitFocusToolbarModifier(focus: focus, items: items))
    }

    /**
     Attaches an accessory toolbar with Previous / Next / Done for any `CaseIterable` enum bound to a `@FocusState`.
     */
    func iqKeyboardToolbar<Field: Hashable & CaseIterable>(focus: FocusState<Field?>.Binding) -> some View {
        self.iqKeyboardToolbar(focus: Binding(
            get: { focus.wrappedValue },
            set: { focus.wrappedValue = $0 }
        ))
    }
}

#endif
