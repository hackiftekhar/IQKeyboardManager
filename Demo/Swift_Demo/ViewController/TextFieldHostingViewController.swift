//
//  TextFieldHostingViewController.swift
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

import UIKit
import SwiftUI
import IQKeyboardManagerSwift

/**
 Demo hosting controller for SwiftUI TextFieldView.
 
 This demonstrates how to use IQSwiftUIHostingController for automatic toolbar management.
 The hosting controller will automatically check if its SwiftUI content type (TextFieldView)
 is in the disabledSwiftUIToolbarTypes or enabledSwiftUIToolbarTypes arrays and
 manage its toolbar state accordingly.
 
 To test toolbar disabling:
 1. Go to "Custom" section in demo
 2. Toggle "Disable Toolbar" switch
 3. Navigate to this SwiftUI view
 4. Notice that toolbars are disabled for the text fields
 
 This can also be controlled programmatically:
 ```swift
 // Disable toolbar for this SwiftUI view type
 IQKeyboardManager.shared.disabledSwiftUIToolbarTypes.append(TextFieldView.self)
 
 // Or enable toolbar for this SwiftUI view type
 IQKeyboardManager.shared.enabledSwiftUIToolbarTypes.append(TextFieldView.self)
 ```
 */
@available(iOS 15.0, *)
class TextFieldHostingViewController: IQSwiftUIHostingController<TextFieldView> {

    required init?(coder: NSCoder) {
         super.init(coder: coder, rootView: TextFieldView())
     }
}
