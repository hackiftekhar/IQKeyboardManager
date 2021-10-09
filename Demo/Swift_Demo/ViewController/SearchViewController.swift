//
//  SearchViewController.swift
//  Demo
//
//  Created by IEMacBook01 on 16/06/16.
//  Copyright © 2016 Iftekhar. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {

    let dataList = [["name": "David Smith", "email": "david@example.com"],
                    ["name": "Kevin John", "email": "kjohn@example.com"],
                    ["name": "Jacob Brown", "email": "jacobb@example.com"],
                    ["name": "Paul Johnson", "email": "johnsonp@example.com"],
                    ["name": "Sam William", "email": "willsam@example.com"],
                    ["name": "Brian Taylor", "email": "btaylor@example.com"],
                    ["name": "Charles Smith", "email": "charless@example.com"],
                    ["name": "Andrew White", "email": "awhite@example.com"],
                    ["name": "Matt Thomas", "email": "mthomas@example.com"],
                    ["name": "Michael Clark", "email": "clarkm@example.com"]]

    var filteredList = [[String: String]]()

    var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.scopeButtonTitles = ["All", "Name", "Email"]
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.sizeToFit()
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            self.tableView.tableHeaderView = self.searchController.searchBar
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func searchForText(_ searchText: String?, scope: Int) {

        if let text = searchText {

            if text.isEmpty == false {
                if scope == 0 {
                    self.filteredList = self.dataList.filter({ (obj: [String: String]) -> Bool in

                        if obj["name"]?.contains(text) == true || obj["email"]?.contains(text) == true {
                            return true
                        } else {
                            return false
                        }
                    })
                } else if scope == 1 {
                    self.filteredList = self.dataList.filter({ (obj: [String: String]) -> Bool in

                        if obj["name"]?.contains(text) == true || obj["email"]?.contains(text) == true {
                            return true
                        } else {
                            return false
                        }
                    })
                } else if scope == 2 {
                    self.filteredList = self.dataList.filter({ (obj: [String: String]) -> Bool in

                        if obj["email"]?.contains(text) == true {
                            return true
                        } else {
                            return false
                        }
                    })
                }
            } else {
                self.filteredList = self.dataList
            }
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        self.searchForText(searchController.searchBar.text, scope: searchController.searchBar.selectedScopeButtonIndex)
        self.tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.updateSearchResults(for: self.searchController)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if searchController.isActive == false {
            return dataList.count
        } else {
            return filteredList.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")

        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "UITableViewCell")
        }

        if searchController.isActive == false {
            cell?.textLabel?.text         = dataList[indexPath.row]["name"]
            cell?.detailTextLabel?.text   = dataList[indexPath.row]["email"]
        } else {
            cell?.textLabel?.text         = filteredList[indexPath.row]["name"]
            cell?.detailTextLabel?.text   = filteredList[indexPath.row]["email"]
        }

        return cell!
    }
}
