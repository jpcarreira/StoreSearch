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
#import <AFNetworking/AFNetworking.h>
#import "DetailViewController.h"
#import "LandscapeViewController.h"
#import "Search.h"

// defining the cell identifier for the search result cell
static NSString * const searchResultIdentifier = @"SearchResultCell";

// defining the cell identifier for the nothing found result cell
static NSString * const nothingFoundIdentifier = @"NothingFoundCell";

// defining the cell identifier for the loading cell
static NSString * const loadingCellIdentifier = @"LoadingCell";


// delegates: UITableViewDataSource and UITableViewDelegate (because this isn't a UITableViewController)
// delegate: UISearchBarDelegate (to handle searches)
@interface SearchViewController ()  <UITableViewDataSource,
                                    UITableViewDelegate,
                                    UISearchBarDelegate>

@property(nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property(nonatomic, weak) IBOutlet UITableView *tableView;
@property(nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation SearchViewController
{
    // ivars
    
    // ivar for Search object
    Search *_search;
    
    // ivar for the landscape view controller
    // (this ivar will allow to detect the device's current orientation)
    LandscapeViewController *_landscapeViewController;
    
    // ivar for the status bar style (which changes with device orientation)
    UIStatusBarStyle _statusBarStyle;
    
    // ivar for the details view controller
    // (this ivar will allow to dismiss the DetailsViewController when going to landscap)
    // (setting a weak pointer will allow the popup window to dealloc when we change to landscape)
    __weak DetailViewController *_detailViewController;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // sizing the table view so avoid having the search bar hiding the first row
    // (by adding 64 points: 20 for the status bar and 44 for the search bar)
    self.tableView.contentInset = UIEdgeInsetsMake(108.0, 0.0, 0.0, 0.0);
    
    // register the nib file for the custom search result cell
    UINib *cellNib = [UINib nibWithNibName:searchResultIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:searchResultIdentifier];
    
    // registering the nib file for the nothing found cell
    cellNib = [UINib nibWithNibName:nothingFoundIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:nothingFoundIdentifier];
    
    // register the nib file for the loading cell
    cellNib = [UINib nibWithNibName:loadingCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:loadingCellIdentifier];
    
    // setting the heigth equal to the cell designed in the xib
    self.tableView.rowHeight = 80;
    
    // making the keyboard immediatly available
    [self.searchBar becomeFirstResponder];
    
    // setting a default status bar style
    _statusBarStyle = UIStatusBarStyleDefault;
    
#warning remove this later
    self.searchBar.text = @"Benfica";
}


// called before the interface begins rotating
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // this is an override so we should call the superclass method
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // setting the correct controller to display according to orientation
    if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        [self hideLandscapeViewWithDuration:duration];
    }
    else
    {
        [self showLandscapeViewWithDuration:duration];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


# pragma mark - instance methods


// handles network errors
-(void)showNetworkError
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Whoops..."
                              message:@"error reading from the iTunes store. Please try again."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
}


// search logic
-(void)performSearch
{
    // creating the Search object
    _search = [[Search alloc] init];
    NSLog(@"allocated...");
    
    // performing the search as responsability of the Search object
    [_search performSearchForText:self.searchBar.text category:self.segmentedControl.selectedSegmentIndex completion:^(BOOL success){
        if(!success)
        {
            [self showNetworkError];
        }
        // informing the LandscapeViewController that the search is succesfull
        [_landscapeViewController searchResultsReceived];
        [self.tableView reloadData];
    }];
    
    // reloading table
    [self.tableView reloadData];
    
    // dismissing keyboard
    [self.searchBar resignFirstResponder];
}


// showing landscape view controller
-(void)showLandscapeViewWithDuration:(NSTimeInterval)duration
{
    // if it's nill it means we're in portrait and will transition to landscape
    if(_landscapeViewController == nil)
    {
        // creating the view controller
        _landscapeViewController = [[LandscapeViewController alloc] initWithNibName:@"LandscapeViewController" bundle:nil];
        
        // "passing" the seach results to the controller
        _landscapeViewController.search = _search;
        
        // setting the framesize
        _landscapeViewController.view.frame = self.view.bounds;
        
        // setting alpha to 0 (animation purpose)
        _landscapeViewController.view.alpha = 0.0f;
        
        // adding the created viewcontroller's view as subview of the "portrait" view controller
        [self.view addSubview:_landscapeViewController.view];
        
        // defining the hierarchy
        [self addChildViewController:_landscapeViewController];
        
        // animation
        [UIView animateWithDuration:duration animations:
         ^{
             // concerning the view controller itself
            _landscapeViewController.view.alpha = 1.0f;
             
             // concerning the status bar
             _statusBarStyle = UIStatusBarStyleLightContent;
             [self setNeedsStatusBarAppearanceUpdate];
        }
        completion:
         ^(BOOL finished)
        {
            [_landscapeViewController didMoveToParentViewController:self];
        }];
        
        // hiding keyboard
        [self.searchBar resignFirstResponder];
        
        // closing the popup
        [_detailViewController dismissFromParentViewControllerWithAnimationType:DetailViewControllerAnimationTypeFade];
    }
}


// hiding landscape view controller
-(void)hideLandscapeViewWithDuration:(NSTimeInterval)duration
{
    // if it's not nil it means we're in landscape and transitioning to portrait
    if(_landscapeViewController != nil)
    {
        [_landscapeViewController willMoveToParentViewController:nil];
        
        // animation
        [UIView animateWithDuration:duration animations:
         ^{
              // concerning the view controller itself
            _landscapeViewController.view.alpha = 0.0f;
             
             // concerning the status bar
             _statusBarStyle = UIStatusBarStyleDefault;
             [self setNeedsStatusBarAppearanceUpdate];
        }
        completion:
         ^(BOOL finished)
        {
            [_landscapeViewController.view removeFromSuperview];
            [_landscapeViewController removeFromParentViewController];
            
            // explicit set to nil to deallocate the view controller
            _landscapeViewController = nil;
        }];
    }
}


// returns current UIStatusBarStyle
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return _statusBarStyle;
}


# pragma mark - Action methods

-(IBAction)segmentChanged:(UISegmentedControl *)sender
{
    // only searches if there's a previous search
    if(_search != nil)
    {
        [self performSearch];
    }
}


# pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // haven't searched yet
    if(_search == nil)
    {
        return 0;
    }
    // if it's loading data will display a single cell (loading cell)
    else if(_search.isLoading)
    {
        return 1;
    }
    // nothing found on the search
    else if([_search.searchResults count] == 0)
    {
        return 1;
    }
    else
    {
        return [_search.searchResults count];
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
    
    // display "loading cell" if the app is loading data from the webservice
    if(_search.isLoading)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:loadingCellIdentifier forIndexPath:indexPath];
        
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:100];
        [spinner startAnimating];
        
        return cell;
    }
    
    // returning a "nothing found" cell if the array is empty
    else if([_search.searchResults count] == 0)
    {
        return [tableView dequeueReusableCellWithIdentifier:nothingFoundIdentifier forIndexPath:indexPath];
    }
    // with at least one search result we return a "search result" cell
    else
    {
        // dequeuing the search result cell
        SearchResultCell *cell = (SearchResultCell *)[tableView dequeueReusableCellWithIdentifier:searchResultIdentifier forIndexPath:indexPath];
        
        // getting the search result
        SearchResult *searchResult = _search.searchResults[indexPath.row];
        
        // configuring the cell
        [cell configureForSearchResult:searchResult];
        
        return cell;
    }
}


# pragma mark - UISearchBarDelegate

// with AFNetworking
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // performs search
    [self performSearch];
}


# pragma mark - UISearchBarDelegate protocol


- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    // positioning the search bar attached to status bar
    return UIBarPositionTopAttached;
}


# pragma mark - UITableViewDelegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // dismissing the keyboard
    [self.searchBar resignFirstResponder];
    
    // deselects a tapped row with an animation
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // enabling the popup screen
    // (as this app doesn't use storyboards we can't make segues and to show a new view controller
    // we need to alloc and init it manually)
    DetailViewController *controller = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    
    // setting the controller's SearchResult with the current one
    SearchResult *searchResult = _search.searchResults[indexPath.row];
    controller.searchResult = searchResult;
    
    // all the code below was moved to DetailsViewController
    /*
    // resizing the DetailViewController's view size to the same as the SearchViewController
    controller.view.frame = self.view.frame;
    
    // instead of using below, which is the equivalent to a modal segue
    //[self presentViewController:controller animated:YES completion:nil];
    // we'll use view controller's containment APIs, adding the DetailViewController as a child view controller (takes 3 steps)
    // 1. add the new view controller as a subview
    [self.view addSubview:controller.view];
    // 2. tell the current view controller that DetailsViewController is managing the screen
    [self addChildViewController:controller];
    // 3. tell DetailsViewController that this controller is it's parent
    [controller didMoveToParentViewController:self];
     */
    
    [controller presentInParentViewController:self];
    
    // updating the respective ivar
    _detailViewController = controller;
}


// ensures that we can only select rows with actual search results
// (this way we can't pick a cell that shows 'no results found' or 'loading')
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([_search.searchResults count] == 0 || _search.isLoading)
    {
        return nil;
    }
    else
    {
        return indexPath;
    }
}

@end
