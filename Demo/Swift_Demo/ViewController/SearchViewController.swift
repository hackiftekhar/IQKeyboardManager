//
//  SearchViewController.swift
//  Demo
//
//  Created by IEMacBook01 on 16/06/16.
//  Copyright © 2016 Iftekhar. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {

    let dataList = [["name":"David Smith","email":"david@example.com"],
                    ["name":"Kevin John","email":"kjohn@example.com"],
                    ["name":"Jacob Brown","email":"jacobb@example.com"],
                    ["name":"Paul Johnson","email":"johnsonp@example.com"],
                    ["name":"Sam William","email":"willsam@example.com"],
                    ["name":"Brian Taylor","email":"btaylor@example.com"],
                    ["name":"Charles Smith","email":"charless@example.com"],
                    ["name":"Andrew White","email":"awhite@example.com"],
                    ["name":"Matt Thomas","email":"mthomas@example.com"],
                    ["name":"Michael Clark","email":"clarkm@example.com"]]
    
    var filteredList = [[String:String]]()
    
    let searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.scopeButtonTitles = ["All", "Name", "Email"]
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.definesPresentationContext = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    func searchForText(searchText:String?, scope:Int) {
        
        if let text = searchText {
            
            if (text.characters.count != 0)
            {
                if (scope == 0)
                {
                    self.filteredList = self.dataList.filter({ (obj : [String : String]) -> Bool in
                        
                        if obj["name"]?.containsString(text) == true || obj["email"]?.containsString(text) == true {
                            return true
                        } else {
                            return false
                        }
                    })
                }
                else if (scope == 1)
                {
                    self.filteredList = self.dataList.filter({ (obj : [String : String]) -> Bool in
                        
                        if obj["name"]?.containsString(text) == true || obj["email"]?.containsString(text) == true {
                            return true
                        } else {
                            return false
                        }
                    })
                }
                else if (scope == 2)
                {
                    self.filteredList = self.dataList.filter({ (obj : [String : String]) -> Bool in
                        
                        if obj["email"]?.containsString(text) == true {
                            return true
                        } else {
                            return false
                        }
                    })
                }
            }
            else
            {
                self.filteredList = self.dataList;
            }
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.searchForText(searchController.searchBar.text, scope: searchController.searchBar.selectedScopeButtonIndex)
        self.tableView.reloadData()
    }

    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.updateSearchResultsForSearchController(self.searchController)
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.active == false {
            return dataList.count
        } else {
            return filteredList.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell")

        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "UITableViewCell")
        }

        if searchController.active == false {
            cell?.textLabel?.text         = dataList[indexPath.row]["name"];
            cell?.detailTextLabel?.text   = dataList[indexPath.row]["email"];
        } else {
            cell?.textLabel?.text         = filteredList[indexPath.row]["name"];
            cell?.detailTextLabel?.text   = filteredList[indexPath.row]["email"];
        }

        return cell!
    }
}
