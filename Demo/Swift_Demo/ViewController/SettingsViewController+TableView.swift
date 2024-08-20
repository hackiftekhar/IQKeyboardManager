//
//  SettingsViewController+TableView.swift
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
import IQKeyboardManagerSwift
import IQKeyboardToolbarManager

extension SettingsViewController {

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0:
            if IQKeyboardManager.shared.isEnabled == true {

                let properties = keyboardManagerProperties[section]

                return properties.count
            } else {
                return 1
            }

        case 1:
            if IQKeyboardToolbarManager.shared.isEnabled == false {
                return 1
            } else if !IQKeyboardToolbarManager.shared.toolbarConfiguration.placeholderConfiguration.showPlaceholder {
                return 4
            } else {
                let properties = keyboardManagerProperties[section]
                return properties.count
            }

        case 2:

            if IQKeyboardManager.shared.keyboardConfiguration.overrideAppearance == true {

                let properties = keyboardManagerProperties[section]

                return properties.count
            } else {
                return 1
            }

        case 3, 4, 5:
            let properties = keyboardManagerProperties[section]

            return properties.count

        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        return sectionTitles[section]
    }

    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell",
                                                               for: indexPath) as? SwitchTableViewCell else {
                    fatalError("Can't dequeue cell")
                }

                cell.switchEnable.isEnabled = true
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                cell.switchEnable.isOn = IQKeyboardManager.shared.isEnabled
                cell.switchEnable.removeTarget(nil, action: nil, for: .allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.enableAction(_:)), for: .valueChanged)
                return cell
            case 1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "StepperTableViewCell",
                                                               for: indexPath) as? StepperTableViewCell else {
                    fatalError("Can't dequeue cell")
                }

                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                cell.stepper.value = Double(IQKeyboardManager.shared.keyboardDistance)
                let distance = IQKeyboardManager.shared.keyboardDistance
                let text: String = NSString(format: "%.0f", distance) as String
                cell.labelStepperValue.text = text
                cell.stepper.removeTarget(nil, action: nil, for: .allEvents)
                cell.stepper.addTarget(self, action: #selector(self.keyboardDistanceFromTextFieldAction(_:)),
                                       for: .valueChanged)
                return cell
            case 2:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell",
                                                               for: indexPath) as? SwitchTableViewCell else {
                    fatalError("Can't dequeue cell")
                }

                cell.switchEnable.isEnabled = true
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                cell.switchEnable.isOn = IQKeyboardManager.shared.layoutIfNeededOnUpdate
                cell.switchEnable.removeTarget(nil, action: nil, for: .allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.layoutIfNeededOnUpdateAction(_:)),
                                            for: .valueChanged)
                return cell
            default:    break
            }
        case 1:
            switch indexPath.row {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell",
                                                               for: indexPath) as? SwitchTableViewCell else {
                    fatalError("Can't dequeue cell")
                }

                cell.switchEnable.isEnabled = true
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                cell.switchEnable.isOn = IQKeyboardToolbarManager.shared.isEnabled
                cell.switchEnable.removeTarget(nil, action: nil, for: .allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.enableAutoToolbarAction(_:)),
                                            for: .valueChanged)
                return cell
            case 1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "NavigationTableViewCell",
                                                               for: indexPath) as? NavigationTableViewCell else {
                    fatalError("Can't dequeue cell")
                }

                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                return cell
            case 2:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell",
                                                               for: indexPath) as? SwitchTableViewCell else {
                    fatalError("Can't dequeue cell")
                }

                cell.switchEnable.isEnabled = true
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                cell.switchEnable.isOn = IQKeyboardToolbarManager.shared.toolbarConfiguration.useTextInputViewTintColor
                cell.switchEnable.removeTarget(nil, action: nil, for: .allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.shouldToolbarUsesTextFieldTintColorAction(_:)),
                                            for: .valueChanged)
                return cell
            case 3:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell",
                                                               for: indexPath) as? SwitchTableViewCell else {
                    fatalError("Can't dequeue cell")
                }

                cell.switchEnable.isEnabled = true
                let subtitle = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = subtitle
                let toolbarConfig = IQKeyboardToolbarManager.shared.toolbarConfiguration
                cell.switchEnable.isOn = toolbarConfig.placeholderConfiguration.showPlaceholder
                cell.switchEnable.removeTarget(nil, action: nil, for: .allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.shouldShowToolbarPlaceholder(_:)),
                                            for: .valueChanged)
                return cell
            case 4:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "NavigationTableViewCell",
                                                               for: indexPath) as? NavigationTableViewCell else {
                    fatalError("Can't dequeue cell")
                }

                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                return cell
            case 5:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ColorTableViewCell",
                                                               for: indexPath) as? ColorTableViewCell else {
                    fatalError("Can't dequeue cell")
                }

                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                cell.selectedColorView.backgroundColor = IQKeyboardToolbarManager.shared.toolbarConfiguration.tintColor
                cell.selectedColorView.layer.borderColor = UIColor.lightGray.cgColor
                cell.selectedColorView.layer.borderWidth = 1.0
                return cell
            case 6:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageSwitchTableViewCell",
                                                               for: indexPath) as? ImageSwitchTableViewCell else {
                    fatalError("Can't dequeue cell")
                }

                cell.switchEnable.isEnabled = true
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                let configuration = IQKeyboardToolbarManager.shared.toolbarConfiguration.doneBarButtonConfiguration
                cell.arrowImageView.image = configuration?.image
                cell.switchEnable.isOn = configuration?.image != nil
                cell.switchEnable.removeTarget(nil, action: nil, for: .allEvents)
                cell.switchEnable.addTarget(self,
                                            action: #selector(self.toolbarDoneBarButtonItemImage(_:)),
                                            for: .valueChanged)
                return cell
            case 7:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell",
                                                               for: indexPath) as? TextFieldTableViewCell else {
                    fatalError("Can't dequeue cell")
                }

                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                let configuration = IQKeyboardToolbarManager.shared.toolbarConfiguration.doneBarButtonConfiguration
                cell.textField.text = configuration?.title
                cell.textField.tag = 17
                cell.textField.delegate = self
                return cell
            default:    break
            }
        case 2:
            switch indexPath.row {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell",
                                                               for: indexPath) as? SwitchTableViewCell else {
                    fatalError("Can't dequeue cell")
                }

                cell.switchEnable.isEnabled = true
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                cell.switchEnable.isOn = IQKeyboardManager.shared.keyboardConfiguration.overrideAppearance
                cell.switchEnable.removeTarget(nil, action: nil, for: .allEvents)
                cell.switchEnable.addTarget(self,
                                            action: #selector(self.overrideKeyboardAppearanceAction(_:)),
                                            for: .valueChanged)
                return cell
            case 1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "NavigationTableViewCell",
                                                               for: indexPath) as? NavigationTableViewCell else {
                    fatalError("Can't dequeue cell")
                }

                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                return cell
            default:
                break
            }
        case 3:
            switch indexPath.row {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell",
                                                               for: indexPath) as? SwitchTableViewCell else {
                    fatalError("Can't dequeue cell")
                }

                cell.switchEnable.isEnabled = true
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                cell.switchEnable.isOn = IQKeyboardManager.shared.resignOnTouchOutside
                cell.switchEnable.removeTarget(nil, action: nil, for: .allEvents)
                cell.switchEnable.addTarget(self,
                                            action: #selector(self.shouldResignOnTouchOutsideAction(_:)),
                                            for: .valueChanged)
                return cell
            default:    break
            }
        case 4:
            switch indexPath.row {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell",
                                                               for: indexPath) as? SwitchTableViewCell else {
                    fatalError("Can't dequeue cell")
                }

                cell.switchEnable.isEnabled = true
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                cell.switchEnable.isOn = IQKeyboardToolbarManager.shared.playInputClicks
                cell.switchEnable.removeTarget(nil, action: nil, for: .allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.shouldPlayInputClicksAction(_:)),
                                            for: .valueChanged)
                return cell
            default:    break
            }
        case 5:
            switch indexPath.row {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell",
                                                               for: indexPath) as? SwitchTableViewCell else {
                    fatalError("Can't dequeue cell")
                }

                cell.switchEnable.isEnabled = true
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                cell.switchEnable.isOn = IQKeyboardManager.shared.isDebuggingEnabled
                cell.switchEnable.removeTarget(nil, action: nil, for: .allEvents)
                cell.switchEnable.addTarget(self, action: #selector(self.enableDebugging(_:)), for: .valueChanged)
                return cell
            default:    break
            }
        default:    break
        }

        return UITableViewCell()
    }
    // swiftlint:enable cyclomatic_complexity
    // swiftlint:enable function_body_length
}
