//
//  IQKeyboardManager+ToolbarManager
//  https://github.com/hackiftekhar/IQKeyboardManager
//  Copyright (c) 2013-24 Iftekhar Qurashi.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

@available(iOSApplicationExtension, unavailable)
@MainActor
@objc internal final class IQKeyboardToolbarManager: NSObject {

    let textInputViewObserver: IQTextFieldViewListener = IQTextFieldViewListener()

    /**
     Automatic add the IQToolbar functionality. Default is YES.
     */
    @objc var enableAutoToolbar: Bool = true {
        didSet {
            reloadInputViews()
        }
    }

    /**
     Configurations related to the toolbar display over the keyboard.
     */
    @objc var toolbarConfiguration: IQToolbarConfiguration = .init()

    // MARK: UISound handling

    /**
     If YES, then it plays inputClick sound on next/previous/done click.
     */
    @objc var playInputClicks: Bool = true

    /**
     Disable automatic toolbar creation within the scope of disabled toolbar viewControllers classes.
     Within this scope, 'enableAutoToolbar' property is ignored. Class should be kind of UIViewController.
     */
    @objc var disabledToolbarClasses: [UIViewController.Type] = [
        UIAlertController.self,
        UIInputViewController.self
    ]

    /**
     Enable automatic toolbar creation within the scope of enabled toolbar viewControllers classes.
     Within this scope, 'enableAutoToolbar' property is ignored. Class should be kind of UIViewController.
     If same Class is added in disabledToolbarClasses list, then enabledToolbarClasses will be ignore.
     */
    @objc var enabledToolbarClasses: [UIViewController.Type] = []

    /**
     Allowed subclasses of UIView to add all inner textField,
     this will allow to navigate between textField contains in different superview.
     Class should be kind of UIView.
     */
    @objc var toolbarPreviousNextAllowedClasses: [UIView.Type] = [
        UITableView.self,
        UICollectionView.self,
        IQDeepResponderContainerView.self,
        IQPreviousNextView.self
    ]

    @objc public override init() {
        super.init()

        addTextInputViewObserverForToolbar()

        // (Bug ID: #550)
        // Loading IQToolbar, IQTitleBarButtonItem, IQBarButtonItem to fix first time keyboard appearance delay
        // If you experience exception breakpoint issue at below line then try these solutions
        // https://stackoverflow.com/questions/27375640/all-exception-break-point-is-stopping-for-no-reason-on-simulator
        DispatchQueue.main.async {
            let textField: UITextField = UITextField()
            textField.iq.addDone(target: nil, action: #selector(self.doneAction(_:)))
            textField.iq.addPreviousNextDone(target: nil, previousAction: #selector(self.previousAction(_:)),
                                             nextAction: #selector(self.nextAction(_:)),
                                             doneAction: #selector(self.doneAction(_:)))
        }
    }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
private extension IQKeyboardToolbarManager {

    private func removeTextInputViewObserverForToolbar() {
        textInputViewObserver.unregisterSizeChange(identifier: "TextInputViewObserverForToolbar")
    }

    private func addTextInputViewObserverForToolbar() {
        textInputViewObserver.registerTextFieldViewChange(identifier: "TextInputViewObserverForToolbar",
                                             changeHandler: { [weak self] info in
            guard let self = self else { return }
            guard (info.textInputView as UIView).iq.isAlertViewTextField() == false else {
                return
            }

            switch info.name {
            case .beginEditing:
                self.reloadInputViews()
            case .endEditing:
                removeToolbarIfRequired(of: info.textInputView)
            }
        })
    }
}
