//
//  SettingsViewController+TableView.swift
//  DemoSwift
//
//  Created by Iftekhar on 10/19/23.
//  Copyright © 2023 Iftekhar. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

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
            if IQKeyboardManager.shared.enable == true {

                let properties = keyboardManagerProperties[section]

                return properties.count
            } else {
                return 1
            }

        case 1:
            if IQKeyboardManager.shared.enableAutoToolbar == false {
                return 1
            } else if IQKeyboardManager.shared.toolbarConfiguration.placeholderConfiguration.showPlaceholder == false {
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
                cell.switchEnable.isOn = IQKeyboardManager.shared.enable
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
                cell.stepper.value = Double(IQKeyboardManager.shared.keyboardDistanceFromTextField)
                let distance = IQKeyboardManager.shared.keyboardDistanceFromTextField
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
                cell.switchEnable.isOn = IQKeyboardManager.shared.enableAutoToolbar
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
                cell.switchEnable.isOn = IQKeyboardManager.shared.toolbarConfiguration.useTextFieldTintColor
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
                let toolbarConfig = IQKeyboardManager.shared.toolbarConfiguration
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
                cell.colorPickerTextField.selectedColor = IQKeyboardManager.shared.toolbarConfiguration.tintColor
                cell.colorPickerTextField.tag = 15
                cell.colorPickerTextField.delegate = self
                return cell
            case 6:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageSwitchTableViewCell",
                                                               for: indexPath) as? ImageSwitchTableViewCell else {
                    fatalError("Can't dequeue cell")
                }

                cell.switchEnable.isEnabled = true
                cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row]
                cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row]
                let doneButtonConfiguration = IQKeyboardManager.shared.toolbarConfiguration.doneBarButtonConfiguration
                cell.arrowImageView.image = doneButtonConfiguration?.image
                cell.switchEnable.isOn = doneButtonConfiguration?.image != nil
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
                cell.textField.text = IQKeyboardManager.shared.toolbarConfiguration.doneBarButtonConfiguration?.title
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
                cell.switchEnable.isOn = IQKeyboardManager.shared.playInputClicks
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
                cell.switchEnable.isOn = IQKeyboardManager.shared.enableDebugging
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
