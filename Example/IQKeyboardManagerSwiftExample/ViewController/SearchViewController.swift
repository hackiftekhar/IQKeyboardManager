//
//  SearchViewController.swift
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

class SearchViewController: BaseTableViewController, UISearchResultsUpdating, UISearchBarDelegate {

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
//        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.scopeButtonTitles = ["All", "Name", "Email"]
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.sizeToFit()
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            self.tableView.tableHeaderView = self.searchController.searchBar
        }
    }

    func searchForText(_ searchText: String?, scope: Int) {

        guard let text = searchText, !text.isEmpty else {
            self.filteredList = self.dataList
            return
        }

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
