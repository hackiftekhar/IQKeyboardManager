//
//  UITableView+Extension.swift
//  DemoSwift
//
//  Created by Iftekhar on 10/19/23.
//  Copyright © 2023 Iftekhar. All rights reserved.
//

import UIKit

extension UITableView {
    func dequeueCell<T: UITableViewCell>(_: T.Type, for indexPath: IndexPath) -> T {
        let identifier: String = String(describing: T.self)
        guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Could not dequeue \(T.self)")
        }

        return cell
    }

    func dequeueHeaderFooter<T: UITableViewHeaderFooterView>(_: T.Type) -> T {
        let identifier: String = String(describing: T.self)
        if let view = dequeueReusableHeaderFooterView(withIdentifier: identifier) as? T {
            return view
        } else {
            return T(reuseIdentifier: identifier)
        }
    }
}
