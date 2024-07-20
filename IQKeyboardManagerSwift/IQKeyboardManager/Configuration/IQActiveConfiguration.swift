//
//  IQActiveConfiguration.swift
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
import IQKeyboardNotification
import IQTextInputViewNotification
import IQKeyboardManagerCore

@available(iOSApplicationExtension, unavailable)
@MainActor
internal final class IQActiveConfiguration {

    private let keyboardObserver: IQKeyboardNotification = IQKeyboardNotification()
    internal let textInputViewObserver: IQTextInputViewNotification = IQTextInputViewNotification()

    private var changeObservers: [AnyHashable: ConfigurationCompletion] = [:]

    @objc public enum Event: Int {
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

    var rootControllerConfiguration: IQRootControllerConfiguration?

    var isReady: Bool {
        if textInputViewInfo != nil,
           let rootControllerConfiguration = rootControllerConfiguration {
            return rootControllerConfiguration.isReady
        }
        return false
    }

    init() {
        addKeyboardObserver()
        addTextInputViewObserver()
    }

    private func sendEvent() {

        guard let rootControllerConfiguration = rootControllerConfiguration,
              rootControllerConfiguration.isReady else { return }

        if keyboardInfo.isVisible {
            if lastEvent == .hide {
                self.notify(event: .show, keyboardInfo: keyboardInfo, textFieldViewInfo: textInputViewInfo)
            } else {
                self.notify(event: .change, keyboardInfo: keyboardInfo, textFieldViewInfo: textInputViewInfo)
            }
        } else if lastEvent != .hide {
            if rootControllerConfiguration.beginOrientation == rootControllerConfiguration.currentOrientation {
                self.notify(event: .hide, keyboardInfo: keyboardInfo, textFieldViewInfo: textInputViewInfo)
                self.rootControllerConfiguration = nil
            } else if rootControllerConfiguration.hasChanged {
                animate(alongsideTransition: {
                    rootControllerConfiguration.restore()
                }, completion: nil)
            }
        }
    }

    private func updateRootController(info: IQTextInputViewInfo?) {

        guard let info = info,
              let controller: UIViewController = info.textInputView.iq.parentContainerViewController() else {
            if let rootControllerConfiguration = rootControllerConfiguration,
               rootControllerConfiguration.hasChanged {
                animate(alongsideTransition: {
                    rootControllerConfiguration.restore()
                }, completion: nil)
            }
            rootControllerConfiguration = nil
            return
        }

        let newConfiguration = IQRootControllerConfiguration(rootController: controller)

        guard newConfiguration.rootController.view.window != rootControllerConfiguration?.rootController.view.window ||
                newConfiguration.beginOrientation != rootControllerConfiguration?.beginOrientation else { return }

        if rootControllerConfiguration?.rootController != newConfiguration.rootController {

            // If there was an old configuration but things are changed
            if let rootControllerConfiguration = rootControllerConfiguration,
               rootControllerConfiguration.hasChanged {
                animate(alongsideTransition: {
                    rootControllerConfiguration.restore()
                }, completion: nil)
            }
        }

        rootControllerConfiguration = newConfiguration
    }
}

@available(iOSApplicationExtension, unavailable)
extension IQActiveConfiguration {

    var keyboardInfo: IQKeyboardInfo {
        return keyboardObserver.keyboardInfo
    }

    private func addKeyboardObserver() {
        keyboardObserver.subscribe(identifier: "IQActiveConfiguration", changeHandler: { [self] name, _ in

            if let info = textInputViewInfo, keyboardInfo.isVisible {
                if let rootControllerConfiguration = rootControllerConfiguration {
                    let beginIsPortrait: Bool = rootControllerConfiguration.beginOrientation.isPortrait
                    let currentIsPortrait: Bool = rootControllerConfiguration.currentOrientation.isPortrait
                    if beginIsPortrait != currentIsPortrait {
                        updateRootController(info: info)
                    }
                } else {
                    updateRootController(info: info)
                }
            }

            self.sendEvent()

            if name == .didHide {
                updateRootController(info: nil)
            }
        })
    }

    public func animate(alongsideTransition transition: @escaping () -> Void, completion: (() -> Void)? = nil) {
        keyboardObserver.animate(alongsideTransition: transition, completion: completion)
    }
}

@available(iOSApplicationExtension, unavailable)
extension IQActiveConfiguration {

    var textInputViewInfo: IQTextInputViewInfo? {
        guard textInputViewObserver.textFieldView?.iq.isAlertViewTextField() == false else {
            return nil
        }

        return textInputViewObserver.textInputViewInfo
    }

    private func addTextInputViewObserver() {
        textInputViewObserver.subscribe(identifier: "IQActiveConfiguration",
                                                          changeHandler: { [self] info in

            guard info.textInputView.iq.isAlertViewTextField() == false else {
                return
            }

            if info.name == .beginEditing {
                updateRootController(info: info)
                self.sendEvent()
            }
        })
    }
}

@available(iOSApplicationExtension, unavailable)
extension IQActiveConfiguration {

    typealias ConfigurationCompletion = (_ event: Event,
                                         _ keyboardInfo: IQKeyboardInfo,
                                         _ textFieldInfo: IQTextInputViewInfo?) -> Void

    func registerChange(identifier: AnyHashable, changeHandler: @escaping ConfigurationCompletion) {
        changeObservers[identifier] = changeHandler
    }

    func unregisterChange(identifier: AnyHashable) {
        changeObservers[identifier] = nil
    }

    private func notify(event: Event, keyboardInfo: IQKeyboardInfo, textFieldViewInfo: IQTextInputViewInfo?) {
        lastEvent = event

        for block in changeObservers.values {
            block(event, keyboardInfo, textFieldViewInfo)
        }
    }
}
