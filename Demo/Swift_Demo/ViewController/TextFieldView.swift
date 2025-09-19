//
//  TextFieldView.swift
//  DemoSwift
//
//  Created by Iftekhar on 11/6/23.
//  Copyright © 2023 Iftekhar. All rights reserved.
//

import SwiftUI

@available(iOS 15.0, *)
struct TextFieldView: View {

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
            VStack(spacing: 40) {
                Text("SwiftUI Toolbar Demo")
                    .font(.title2)
                    .padding()
                
                Text("This SwiftUI view demonstrates toolbar management. The toolbar behavior can be controlled by modifying IQKeyboardManager.shared.disabledSwiftUIToolbarTypes.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextField("Text Field 1", text: $text1)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Text Field 2", text: $text2)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Text Field 3", text: $text3)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Text Field 4", text: $text4)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Text Field 5", text: $text5)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Text Field 6", text: $text6)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Text Field 7", text: $text7)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Text Field 8", text: $text8)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Text Field 9", text: $text9)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Text Field 10", text: $text10)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
        }
        .background(Color.yellow.opacity(0.1))
        .navigationTitle("SwiftUI")
//        .toolbar {
//            ToolbarItemGroup(placement: .keyboard) {
//                Button("Click me! All") {
//                    print("Clicked all")
//                }
//            }
//        }
    }
}
}

@available(iOS 15.0, *)
struct TextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldView()
    }
}
