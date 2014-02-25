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
    
    // ivar for "fake data"
    NSMutableArray *_searchResults;
    
    // ivar to check is the app is loading data
    BOOL _isLoading;
    
    // ivar for NSOperation
    NSOperationQueue *_queue;
    
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


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _queue = [[NSOperationQueue alloc] init];
    }
    return self;
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


// builds a url from standard string to query iTunes webservice
-(NSURL *)urlWithSearchText:(NSString *)searchText category:(NSInteger)category
{
    // getting the category according to segmented control index
    NSString *categoryName;
    switch(category)
    {
        case 0:
            categoryName = @"";
            break;
        case 1:
            categoryName = @"musicTrack";
            break;
        case 2:
            categoryName = @"software";
            break;
        case 3:
            categoryName = @"ebook";
            break;
    }
    
    // encoding URL from search text (UTF8)
    NSString *escapedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"http://itunes.apple.com/search?term=%@&limit=200&entity=%@", escapedSearchText, categoryName];
    
    //NSLog(@"Index=%i\nCategory='%@'\nURL = '%@'", category, categoryName, urlString);
    
    return [NSURL URLWithString:urlString];
}


// parses the dictionary as the iTunes store as different json data structures according to the products
// the products will be distinguished according to 'kind' and 'wrapperType'
-(void)parseDictionary:(NSDictionary *)dictionary
{
    // the key 'results' corresponds to an array
    NSArray *array = dictionary[@"results"];
    
    // making sure the key 'results' actually exists
    if(array == nil)
    {
        NSLog(@"Expected 'results' array");
        return;
    }
    
    // printing results
    for(NSDictionary *resultDict in array)
    {
        //NSLog(@"WrapperType: %@, kind: %@", resultDict[@"wrapperType"], resultDict[@"kind"]);
        
        SearchResult *searchResult;
        
        // getting 'wrapperType' and 'kind' (ebooks don't have a 'wrapper type' so we need to use 'kind' to identify them)
        NSString *wrapperType = resultDict[@"wrapperType"];
        NSString *kind = resultDict[@"kind"];
        
        // calling the respective parsing method
        if([wrapperType isEqualToString:@"track"])
        {
            searchResult = [self parseTrack:resultDict];
        }
        else if([wrapperType isEqualToString:@"audiobook"])
        {
            searchResult = [self parseAudioBook:resultDict];
        }
        else if([wrapperType isEqualToString:@"software"])
        {
            searchResult = [self parseSoftware:resultDict];
        }
        else if([kind isEqualToString:@"ebook"])
        {
            searchResult = [self parseEBook:resultDict];
        }
        
        // adding to array with results
        if(searchResult != nil)
        {
            [_searchResults addObject:searchResult];
        }
    
    }
}


// parsing tracks
-(SearchResult *)parseTrack:(NSDictionary *)dictionary
{
    SearchResult *searchResult = [[SearchResult alloc] init];
    
    // parsing desired info from tracks dictionary
    searchResult.name = dictionary[@"trackName"];
    searchResult.artistName = dictionary[@"artistName"];
    searchResult.artworkURL60 = dictionary[@"artworkUrl60"];
    searchResult.artworkURL100 = dictionary[@"artworkUrl100"];
    searchResult.storeURL = dictionary[@"trackViewUrl"];
    searchResult.kind = dictionary[@"kind"];
    searchResult.price = dictionary[@"trackPrice"];
    searchResult.currency = dictionary[@"currency"];
    searchResult.genre = dictionary[@"primaryGenreName"];
    
    return searchResult;
}


// parsing audio books
-(SearchResult *)parseAudioBook:(NSDictionary *)dictionary
{
    SearchResult *searchResult = [[SearchResult alloc] init];
    
    // parsing desired info from tracks dictionary
    searchResult.name = dictionary[@"collectionName"];
    searchResult.artistName = dictionary[@"artistName"];
    searchResult.artworkURL60 = dictionary[@"artworkUrl60"];
    searchResult.artworkURL100 = dictionary[@"artworkUrl100"];
    searchResult.storeURL = dictionary[@"collectionViewUrl"];
    // audiobooks don't have a kind field so we have to set it manually
    searchResult.kind = @"audiobook";
    searchResult.price = dictionary[@"collectionPrice"];
    searchResult.currency = dictionary[@"currency"];
    searchResult.genre = dictionary[@"primaryGenreName"];
    
    return searchResult;
}


// parsing apps
-(SearchResult *)parseSoftware:(NSDictionary *)dictionary
{
    SearchResult *searchResult = [[SearchResult alloc] init];
    
    // parsing desired info from tracks dictionary
    searchResult.name = dictionary[@"trackName"];
    searchResult.artistName = dictionary[@"artistName"];
    searchResult.artworkURL60 = dictionary[@"artworkUrl60"];
    searchResult.artworkURL100 = dictionary[@"artworkUrl100"];
    searchResult.storeURL = dictionary[@"trackViewUrl"];
    searchResult.kind = dictionary[@"kind"];
    searchResult.price = dictionary[@"price"];
    searchResult.currency = dictionary[@"currency"];
    searchResult.genre = dictionary[@"primaryGenreName"];
    
    return searchResult;
}


// parsing ebooks
-(SearchResult *)parseEBook:(NSDictionary *)dictionary
{
    SearchResult *searchResult = [[SearchResult alloc] init];
    
    // parsing desired info from tracks dictionary
    searchResult.name = dictionary[@"trackName"];
    searchResult.artistName = dictionary[@"artistName"];
    searchResult.artworkURL60 = dictionary[@"artworkUrl60"];
    searchResult.artworkURL100 = dictionary[@"artworkUrl100"];
    searchResult.storeURL = dictionary[@"trackViewUrl"];
    searchResult.kind = dictionary[@"kind"];
    searchResult.price = dictionary[@"price"];
    searchResult.currency = dictionary[@"currency"];
    // ebooks don't have a 'primaryGenreName' but an array of genres so we have to set it manually
    // (we picks all elements in the array and join them in a single string)
    searchResult.genre = [(NSArray *)dictionary[@"genre"] componentsJoinedByString:@", "];
    
    return searchResult;
}


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
    if([self.searchBar.text length] > 0)
    {
        [self.searchBar resignFirstResponder];
        
        // canceling any previous ongoing request
        // (this will invoke the failure block of AFNetworking)
        [_queue cancelAllOperations];
        
        _isLoading = YES;
        [self.tableView reloadData];
        
        _searchResults = [NSMutableArray arrayWithCapacity:10];
        
        // creating the NSURL object and putting it in NSURLRequest
        NSURL *url = [self urlWithSearchText:self.searchBar.text category:self.segmentedControl.selectedSegmentIndex];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        // AFHTTPRequestOperation takes 2 blocks
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        
        // both blocks can call UIKit methods because they run in the main thread
        // (check AFNetworking documentation)
        [operation setCompletionBlockWithSuccess:
         // success block
         ^(AFHTTPRequestOperation *operation, id responseObject)
         {
             // taking the responseObject and parsing it
             [self parseDictionary:responseObject];
             [_searchResults sortUsingSelector:@selector(compareName:)];
             
             _isLoading = NO;
             [self.tableView reloadData];
         }
         // failure block (when there's a network error or not a valid JSON object)
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             //this block is also called when the operations is cancelled so we need to prevent error display in this case
             if(operation.isCancelled)
             {
                 return;
             }
             
             // feedback to user if something goes wrong
             [self showNetworkError];
             
             _isLoading = NO;
             [self.tableView reloadData];
         }];
        
        // this is a different queue from GCD (here we work with a NSOperationQueue object)
        // (this requires an instance variable that must be initialized in the init method)
        [_queue addOperation:operation];
    }
}


// showing landscape view controller
-(void)showLandscapeViewWithDuration:(NSTimeInterval)duration
{
    // if it's nill it means we're in portrait and will transition to landscape
    if(_landscapeViewController == nil)
    {
        // creating the view controller
        _landscapeViewController = [[LandscapeViewController alloc] initWithNibName:@"LandscapeViewController" bundle:nil];
        
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
        [_detailViewController dismissFromParentViewController];
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
    if(_searchResults != nil)
    {
        [self performSearch];
    }
}


# pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // if it's loading data will display a single cell (loading cell)
    if(_isLoading)
    {
        return 1;
    }
    else if(_searchResults == nil)
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
    
    // display "loading cell" if the app is loading data from the webservice
    if(_isLoading)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:loadingCellIdentifier forIndexPath:indexPath];
        
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:100];
        [spinner startAnimating];
        
        return cell;
    }
    
    // returning a "nothing found" cell if the array is empty
    else if([_searchResults count] == 0)
    {
        return [tableView dequeueReusableCellWithIdentifier:nothingFoundIdentifier forIndexPath:indexPath];
    }
    // with at least one search result we return a "search result" cell
    else
    {
        // dequeuing the search result cell
        SearchResultCell *cell = (SearchResultCell *)[tableView dequeueReusableCellWithIdentifier:searchResultIdentifier forIndexPath:indexPath];
        
        // getting the search result
        SearchResult *searchResult = _searchResults[indexPath.row];
        
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
    SearchResult *searchResult = _searchResults[indexPath.row];
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
    if([_searchResults count] == 0 || _isLoading)
    {
        return nil;
    }
    else
    {
        return indexPath;
    }
}

@end
