//
//  SearchViewController.m
//  StoreSearch
//
//  Created by João Carreira on 19/02/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import "SearchViewController.h"

// model class representing search results
#import "SearchResult.h"

// custom class representing the search cell designed in it's own nib
#import "SearchResultCell.h"

// defining the cell identifier for the search result cell
static NSString * const searchResultIdentifier = @"SearchResultCell";

// defining the cell identifier for the nothing found result cell
static NSString * const nothingFoundIdentifier = @"NothingFoundCell";


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
    
    // register the nib file for the custom search result cell
    UINib *cellNib = [UINib nibWithNibName:searchResultIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:searchResultIdentifier];
    
    // registering the nib file for the nothing found cell
    cellNib = [UINib nibWithNibName:nothingFoundIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:nothingFoundIdentifier];
    
    // setting the heigth equal to the cell designed in the xib
    self.tableView.rowHeight = 80;
    
    // making the keyboard immediatly available
    [self.searchBar becomeFirstResponder];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


# pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_searchResults == nil)
    {
        return 0;
    }
    else if([_searchResults count] == 0)
    {
        return 1;
    }
    else
    {
        return [_searchResults count];
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // using our custom name 'SearchResultCell' (this cell has its own nib file)
    // (further down we'll use SearchResultCell properties representing the labels and image view
    // instead of the "traditional" textLabel or detailTextLabel because this would make text to overlap
    // as both are properties of UITableViewCell and not from SearchResultCell)
    
    // SearchResultCell *cell = (SearchResultCell *)[tableView dequeueReusableCellWithIdentifier:searchResultIdentifier];
    // the above line is equivalent to
    //SearchResultCell *cell = (SearchResultCell *)[tableView dequeueReusableCellWithIdentifier:@"SearchResultCell" forIndexPath:indexPath];
    // passing along the indexPath will work in this case because we registered the nib in viewDidLoad
    
    // returning a "nothing found" cell if the array is empty
    if([_searchResults count] == 0)
    {
        return [tableView dequeueReusableCellWithIdentifier:nothingFoundIdentifier forIndexPath:indexPath];
    }
    // with at least one search result we return a "serch result" cell
    else
    {
        SearchResultCell *cell = (SearchResultCell *)[tableView dequeueReusableCellWithIdentifier:searchResultIdentifier forIndexPath:indexPath];
        
        SearchResult *searchResult = _searchResults[indexPath.row];
        cell.nameLabel.text = searchResult.name;
        cell.artistNameLabel.text = searchResult.artistName;
        return cell;
    }
}


# pragma mark - UISearchBarDelegate


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // dismissing the keyboard
    [searchBar resignFirstResponder];
    
#warning fake data
    
    _searchResults = [NSMutableArray arrayWithCapacity:10];
    
    if(![searchBar.text isEqualToString:@"fcp"])
    {
        for(int i = 0; i < 3; i++)
        {
            SearchResult *searchResult = [[SearchResult alloc] init];
            searchResult.name = [NSString stringWithFormat:@"Fake result %d for", i];
            searchResult.artistName = searchBar.text;
            
            [_searchResults addObject:searchResult];
        }
    }
    
    [self.tableView reloadData];
}


# pragma mark - UISearchBarDelegate protocol


- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    // positioning the search bar attached to status bar
    return UIBarPositionTopAttached;
}


# pragma mark - UITableViewDelegate


// deselects a tapped row with an animation
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


// ensures that we can only select rows with actual search results
// (this way we can't pick a cell that shows 'no results found')
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([_searchResults count] == 0)
    {
        return nil;
    }
    else
    {
        return indexPath;
    }
}

@end
