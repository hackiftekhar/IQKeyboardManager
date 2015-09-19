//
//  OptionsViewController.swift
//  Demo
//
//  Created by Iftekhar on 26/08/15.
//  Copyright (c) 2015 Iftekhar. All rights reserved.
//

protocol OptionsViewControllerDelegate: class {
    
    func optionsViewController(controller : OptionsViewController, index:NSInteger)
}

class OptionsViewController: UITableViewController {

    weak var delegate : OptionsViewControllerDelegate?
    
    var options = [String]()
    
    var selectedIndex : Int = 0
    
        
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("OptionTableViewCell") as! OptionTableViewCell
        
        cell.labelOption.text = options[indexPath.row]
        
        if indexPath.row == self.selectedIndex  {
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }

        return cell
    }

        
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        selectedIndex = indexPath.row
        
        delegate?.optionsViewController(self, index: indexPath.row)
        
        tableView.reloadRowsAtIndexPaths(tableView.indexPathsForVisibleRows!, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
}
