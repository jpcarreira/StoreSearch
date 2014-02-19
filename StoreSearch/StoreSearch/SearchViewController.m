//
//  SearchViewController.m
//  StoreSearch
//
//  Created by João Carreira on 19/02/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResult.h"

// delegates: UITableViewDataSource and UITableViewDelegate (because this isn't a UITableViewController)
// delegate: UISearchBarDelegate (to handle searches)
@interface SearchViewController ()  <UITableViewDataSource,
                                    UITableViewDelegate,
                                    UISearchBarDelegate>

@property(nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property(nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation SearchViewController
{
    // ivars
    
    // ivar for "fake data"
    NSMutableArray *_searchResults;
}


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
    if(_searchResults == nil)
    {
        return 0;
    }
    else
    {
        return [_searchResults count];
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SearchResultCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    // getting the search result
    SearchResult *searchResult = _searchResults[indexPath.row];
    cell.textLabel.text = searchResult.name;
    cell.detailTextLabel.text = searchResult.artistName;
    
    return cell;
}


# pragma mark - UISearchBarDelegate


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // dismissing the keyboard
    [searchBar resignFirstResponder];
    
#warning fake data
    
    _searchResults = [NSMutableArray arrayWithCapacity:10];
    
    for(int i = 0; i < 3; i++)
    {
        SearchResult *searchResult = [[SearchResult alloc] init];
        searchResult.name = [NSString stringWithFormat:@"Fake result %d for", i];
        searchResult.artistName = searchBar.text;
        
        [_searchResults addObject:searchResult];
    }
    
    [self.tableView reloadData];
}


# pragma mark - UISearchBarDelegate protocol


- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    // positioning the search bar attached to status bar
    return UIBarPositionTopAttached;
}

@end
