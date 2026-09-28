//
//  TextFieldView.swift
//  DemoSwift
//
//  Created by Iftekhar on 11/6/23.
//  Copyright © 2023 Iftekhar. All rights reserved.
//

import SwiftUI
import IQKeyboardManagerSwift

@available(iOS 15.0, *)
struct TextFieldView: View {

    enum Field: Int, CaseIterable, Hashable {
        case field1 = 1, field2, field3, field4, field5, field6, field7, field8, field9, field10
    }

    @FocusState private var focusedField: Field?

    @State private var text1 = ""
    @State private var text2 = ""
    @State private var text3 = ""
    @State private var text4 = ""
    @State private var text5 = ""
    @State private var text6 = ""
    @State private var text7 = ""
    @State private var text8 = ""
    @State private var text9 = ""
    @State private var text10 = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                TextField("Text Field 1 (Group A, Order 1)", text: $text1)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .field1)
                    .iqFocus(field: .field1, order: 1, group: "FormGroup")

                TextField("Text Field 2 (Group A, Order 2)", text: $text2)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .field2)
                    .iqFocus(field: .field2, order: 2, group: "FormGroup")

                TextField("Text Field 3 (Group A, Order 3)", text: $text3)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .field3)
                    .iqFocus(field: .field3, order: 3, group: "FormGroup")

                TextField("Text Field 4 (Group A, Order 4)", text: $text4)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .field4)
                    .iqFocus(field: .field4, order: 4, group: "FormGroup")

                TextField("Text Field 5 (Group A, Order 5)", text: $text5)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .field5)
                    .iqFocus(field: .field5, order: 5, group: "FormGroup")

                TextField("Text Field 6 (Group A, Order 6)", text: $text6)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .field6)
                    .iqFocus(field: .field6, order: 6, group: "FormGroup")

                TextField("Text Field 7 (Group A, Order 7)", text: $text7)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .field7)
                    .iqFocus(field: .field7, order: 7, group: "FormGroup")

                TextField("Text Field 8 (Group A, Order 8)", text: $text8)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .field8)
                    .iqFocus(field: .field8, order: 8, group: "FormGroup")

                TextField("Text Field 9 (Group A, Order 9)", text: $text9)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .field9)
                    .iqFocus(field: .field9, order: 9, group: "FormGroup")

                TextField("Text Field 10 (Group A, Order 10)", text: $text10)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .field10)
                    .iqFocus(field: .field10, order: 10, group: "FormGroup")
            }
            .padding()
        }
        .navigationTitle("SwiftUI with IQFocus")
        .iqFocusScope(focus: $focusedField, group: "FormGroup")
    }
}

@available(iOS 15.0, *)
struct TextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldView()
    }
}
