//
//  SearchViewController.m
//  StoreSearch
//
//  Created by João Carreira on 19/02/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import "SearchViewController.h"

// delegates: UITableViewDataSource and UITableViewDelegate (because this isn't a UITableViewController)
// delegate: UISearchBarDelegate (to handle searches)
@interface SearchViewController ()  <UITableViewDataSource,
                                    UITableViewDelegate,
                                    UISearchBarDelegate>

@property(nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property(nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation SearchViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // sizing the table view so avoid having the search bar hiding the first row
    // (by adding 64 points: 20 for the status bar and 44 for the search bar)
    self.tableView.contentInset = UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


# pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning fix this
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#warning fix this
    return 0;
}


# pragma mark - UISearchBarDelegate


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"The search text is: '%@'", searchBar.text);
}

@end
