//
//  IQActiveConfiguration.swift
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
import IQKeyboardCore
import IQKeyboardNotification
import IQTextInputViewNotification

@available(iOSApplicationExtension, unavailable)
@MainActor
internal final class IQActiveConfiguration: NSObject {

    private let keyboardObserver: IQKeyboardNotification = .init()
    private let textInputViewObserver: IQTextInputViewNotification = .init()

    private var changeObservers: [AnyHashable: ConfigurationCompletion] = [:]

    enum Event: Int {
        case hide
        case show
        case change

        var name: String {
            switch self {
            case .hide:
                return "hide"
            case .show:
                return "show"
            case .change:
                return "change"
            }
        }
    }

    private var lastEvent: Event = .hide

    var rootConfiguration: IQRootControllerConfiguration?

    var isReady: Bool {
        if textInputViewInfo != nil,
           let rootConfiguration = rootConfiguration {
            return rootConfiguration.isReady
        }
        return false
    }

    override init() {
        super.init()
        addKeyboardObserver()
        addTextInputViewObserver()
    }

    private func sendEvent() {

        guard let rootConfiguration = rootConfiguration,
              rootConfiguration.isReady else { return }

        if keyboardInfo.isVisible {
            if lastEvent == .hide {
                self.notify(event: .show, keyboardInfo: keyboardInfo, textInputViewInfo: textInputViewInfo)
            } else {
                self.notify(event: .change, keyboardInfo: keyboardInfo, textInputViewInfo: textInputViewInfo)
            }
        } else if lastEvent != .hide {
            if rootConfiguration.beginOrientation == rootConfiguration.currentOrientation {
                self.notify(event: .hide, keyboardInfo: keyboardInfo, textInputViewInfo: textInputViewInfo)
                self.rootConfiguration = nil
            } else if rootConfiguration.hasChanged {
                animate(alongsideTransition: {
                    rootConfiguration.restore()
                }, completion: nil)
            }
        }
    }

    private func updateRootController(textInputView: IQTextInputView?) {

        guard let textInputView: UIView = textInputView,
              let controller: UIViewController = textInputView.iq.parentContainerViewController() else {
            if let rootConfiguration = rootConfiguration,
               rootConfiguration.hasChanged {
                animate(alongsideTransition: {
                    rootConfiguration.restore()
                }, completion: nil)
            }
            rootConfiguration = nil
            return
        }

        let newConfiguration = IQRootControllerConfiguration(rootController: controller)

        guard newConfiguration.rootController.view.window != rootConfiguration?.rootController.view.window ||
                newConfiguration.beginOrientation != rootConfiguration?.beginOrientation else { return }

        if rootConfiguration?.rootController != newConfiguration.rootController {

            // If there was an old configuration but things are changed
            if let rootConfiguration = rootConfiguration,
               rootConfiguration.hasChanged {
                animate(alongsideTransition: {
                    rootConfiguration.restore()
                }, completion: nil)
            }
        }

        rootConfiguration = newConfiguration
    }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
extension IQActiveConfiguration {

    var keyboardInfo: IQKeyboardInfo {
        return keyboardObserver.keyboardInfo
    }

    private func addKeyboardObserver() {
        keyboardObserver.subscribe(identifier: "IQActiveConfiguration", changeHandler: { [weak self] event, endFrame in

            guard let self = self else { return }

            guard keyboardObserver.oldKeyboardInfo.endFrame.height != endFrame.height else { return }

            if let info = textInputViewInfo, keyboardInfo.isVisible {
                if let rootConfiguration = rootConfiguration {
                    let beginIsPortrait: Bool = rootConfiguration.beginOrientation.isPortrait
                    let currentIsPortrait: Bool = rootConfiguration.currentOrientation.isPortrait
                    if beginIsPortrait != currentIsPortrait {
                        updateRootController(textInputView: info.textInputView)
                    }
                } else {
                    updateRootController(textInputView: info.textInputView)
                }
            }

            self.sendEvent()

            if event == .didHide {
                updateRootController(textInputView: nil)
            }
        })
    }

    public func animate(alongsideTransition transition: @escaping () -> Void, completion: (() -> Void)? = nil) {
        keyboardObserver.animate(alongsideTransition: transition, completion: completion)
    }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
extension IQActiveConfiguration {

    var textInputView: (any IQTextInputView)? {
        guard let textInputView: UIView = textInputViewObserver.textInputView,
              textInputView.iq.isAlertViewTextField() == false else {
            return nil
        }

        return textInputViewObserver.textInputView
    }

    var textInputViewInfo: IQTextInputViewInfo? {
        guard let textInputView: UIView = textInputView,
              textInputView.iq.isAlertViewTextField() == false else {
            return nil
        }

        return textInputViewObserver.textInputViewInfo
    }

    private func addTextInputViewObserver() {
        textInputViewObserver.subscribe(identifier: "IQActiveConfiguration",
                                        changeHandler: { [weak self] event, textInputView in

            guard let self = self else { return }

//            print(info.event.name)
            guard (textInputView as UIView).iq.isAlertViewTextField() == false else {
                return
            }

            if event == .beginEditing {
                updateRootController(textInputView: textInputView)
                self.sendEvent()
            }
        })
    }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
extension IQActiveConfiguration {

    typealias ConfigurationCompletion = (_ event: Event,
                                         _ keyboardInfo: IQKeyboardInfo,
                                         _ textInputViewInfo: IQTextInputViewInfo?) -> Void

    func subscribe(identifier: AnyHashable, changeHandler: @escaping ConfigurationCompletion) {
        changeObservers[identifier] = changeHandler
    }

    func unsubscribe(identifier: AnyHashable) {
        changeObservers[identifier] = nil
    }

    private func notify(event: Event, keyboardInfo: IQKeyboardInfo, textInputViewInfo: IQTextInputViewInfo?) {
        lastEvent = event

        for block in changeObservers.values {
            block(event, keyboardInfo, textInputViewInfo)
        }
    }
}
