//
//  SearchViewController.m
//  Demo
//
//  Created by IEMacBook01 on 14/06/16.
//  Copyright © 2016 Iftekhar. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()<UISearchResultsUpdating,UISearchBarDelegate>

@property(nonatomic, strong) NSArray *dataList;
@property(nonatomic, strong) NSArray *filteredList;
@property (strong, nonatomic) UISearchController *searchController;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _dataList = @[@{@"name":@"David Smith",@"email":@"david@example.com"},
                  @{@"name":@"Kevin John",@"email":@"kjohn@example.com"},
                  @{@"name":@"Jacob Brown",@"email":@"jacobb@example.com"},
                  @{@"name":@"Paul Johnson",@"email":@"johnsonp@example.com"},
                  @{@"name":@"Sam William",@"email":@"willsam@example.com"},
                  @{@"name":@"Brian Taylor",@"email":@"btaylor@example.com"},
                  @{@"name":@"Charles Smith",@"email":@"charless@example.com"},
                  @{@"name":@"Andrew White",@"email":@"awhite@example.com"},
                  @{@"name":@"Matt Thomas",@"email":@"mthomas@example.com"},
                  @{@"name":@"Michael Clark",@"email":@"clarkm@example.com"}];

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.scopeButtonTitles = @[@"All",
                                                          @"Name",
                                                          @"Email"];
    self.searchController.searchBar.delegate = self;
    [self.searchController.searchBar sizeToFit];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
}

- (void)searchForText:(NSString *)searchText scope:(NSInteger)scopeOption
{
    if (searchText.length)
    {
        if (scopeOption == 0)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name CONTAINS[cd] %@ OR self.email CONTAINS[cd] %@", searchText, searchText];
            
            self.filteredList = [self.dataList filteredArrayUsingPredicate:predicate];
        }
        else if (scopeOption == 1)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name CONTAINS[cd] %@", searchText];
            self.filteredList = [self.dataList filteredArrayUsingPredicate:predicate];
        }
        else if (scopeOption == 2)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.email CONTAINS[cd] %@", searchText];
            self.filteredList = [self.dataList filteredArrayUsingPredicate:predicate];
        }
    }
    else
    {
        self.filteredList = [self.dataList copy];
    }
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString scope:searchController.searchBar.selectedScopeButtonIndex];
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self updateSearchResultsForSearchController:self.searchController];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_searchController.isActive == NO)
    {
        return _dataList.count;
    }
    else
    {
        return [self.filteredList count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    
    if (_searchController.isActive == NO)
    {
        cell.textLabel.text         = _dataList[indexPath.row][@"name"];
        cell.detailTextLabel.text   = _dataList[indexPath.row][@"email"];
    }
    else
    {
        cell.textLabel.text         = _filteredList[indexPath.row][@"name"];
        cell.detailTextLabel.text   = _filteredList[indexPath.row][@"email"];
    }
    
    return cell;
}

@end
