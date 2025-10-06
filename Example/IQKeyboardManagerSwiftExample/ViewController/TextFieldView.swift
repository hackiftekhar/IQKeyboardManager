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
        VStack(spacing: 40) {
            TextField("Text Field 1", text: $text1)
                .background(Color.white)
            TextField("Text Field 2", text: $text2)
                .background(Color.white)
            TextField("Text Field 3", text: $text3)
                .background(Color.white)
            TextField("Text Field 4", text: $text4)
                .background(Color.white)
            TextField("Text Field 5", text: $text5)
                .background(Color.white)
//                .toolbar {
//                    ToolbarItemGroup(placement: .keyboard) {
//                        Button("Click me 5!") {
//                            print("Clicked 5")
//                        }
//                    }
//                }
            TextField("Text Field 6", text: $text6)
                .background(Color.white)
            TextField("Text Field 7", text: $text7)
                .background(Color.white)
            TextField("Text Field 8", text: $text8)
                .background(Color.white)
            TextField("Text Field 9", text: $text9)
                .background(Color.white)
            TextField("Text Field 10", text: $text10)
                .background(Color.white)
        }
        .padding()
        .background(Color.yellow)
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

@available(iOS 15.0, *)
struct TextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldView()
    }
}
