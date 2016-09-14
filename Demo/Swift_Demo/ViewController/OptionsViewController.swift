//
//  OptionsViewController.swift
//  Demo
//
//  Created by Iftekhar on 26/08/15.
//  Copyright (c) 2015 Iftekhar. All rights reserved.
//

protocol OptionsViewControllerDelegate: class {
    
    func optionsViewController(_ controller : OptionsViewController, index:NSInteger)
}

class OptionsViewController: UITableViewController {

    weak var delegate : OptionsViewControllerDelegate?
    
    var options = [String]()
    
    var selectedIndex : Int = 0
    
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionTableViewCell") as! OptionTableViewCell
        
        cell.labelOption.text = options[(indexPath as NSIndexPath).row]
        
        if (indexPath as NSIndexPath).row == self.selectedIndex  {
            
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }

        return cell
    }

        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedIndex = (indexPath as NSIndexPath).row
        
        delegate?.optionsViewController(self, index: (indexPath as NSIndexPath).row)
        
        tableView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: UITableViewRowAnimation.automatic)
    }
}
