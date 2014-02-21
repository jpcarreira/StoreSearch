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


# pragma mark - instance methods


// builds a url from standard string to query iTunes webservice
-(NSURL *)urlWithSearchText:(NSString *)searchText
{
    // encoding URL from search text (UTF8)
    NSString *escapedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"http://itunes.apple.com/search?term=%@", escapedSearchText];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}


// returns the search result based on url
-(NSString *)performStoreRequestWithURL:(NSURL *)url
{
    NSError *error;
    
    // calling a convenience constructor of NSString that returns a new NSString object with the data it receives from the server
    // (if something goes wrong the string is nil in the error variable says what went wrong)
    NSString *resultString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    
    // checking for errors
    if(resultString == nil)
    {
        NSLog(@"Download Error: %@", error);
        return nil;
    }
    
    return resultString;
}


// parses json data
-(NSDictionary *)parseJson:(NSString *)jsonString
{
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    
    // converts JSON search results to a dictionary
    id resultObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if(resultObject == nil)
    {
        NSLog(@"JSON error: %@", error);
        return nil;
    }
    
    // defensive programming against any unexpected change on the server side
    // (just because serialization was able to turn the string into a valid ObjC object, it doesn't mean it will return a NSDictionary)
    // (that's why we use 'id' for resultObject and then here we check if it's a dictionary, because it can return an NSArray or NSNumber)
    if(![resultObject isKindOfClass:[NSDictionary class]])
    {
        NSLog(@"JSON error: expected dictionary");
        return nil;
    }
    
    return resultObject;
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


// "translates" 'kind' from iTunes store to user-friendly text
-(NSString *)kindForDisplay:(NSString *)kind
{
    if([kind isEqualToString:@"album"])
    {
        return @"Album";
    }
    else if([kind isEqualToString:@"audiobook"])
    {
        return @"Audio Book";
    }
    else if([kind isEqualToString:@"book"])
    {
        return @"Book";
    }
    else if([kind isEqualToString:@"ebook"])
    {
        return @"E-Book";
    }
    else if([kind isEqualToString:@"feature-movie"])
    {
        return @"Movie";
    }
    else if([kind isEqualToString:@"music-video"])
    {
        return @"Music Video";
    }
    else if([kind isEqualToString:@"software"])
    {
        return @"App";
    }
    else if([kind isEqualToString:@"song"])
    {
        return @"Song";
    }
    else if([kind isEqualToString:@"tv-episode"])
    {
        return @"TV Episode";
    }
    else
    {
        return kind;
    }
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
        
        // name label
        SearchResult *searchResult = _searchResults[indexPath.row];
        cell.nameLabel.text = searchResult.name;
        
        // artist name label also contains kind
        NSString *artistName = searchResult.artistName;
        if(artistName == nil)
        {
            artistName = @"Unknown";
        }
        
        NSString *kind = [self kindForDisplay:searchResult.kind];
        
        cell.artistNameLabel.text = [NSString stringWithFormat:@"%@ (%@)", artistName, kind];
        
        return cell;
    }
}


# pragma mark - UISearchBarDelegate


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // only performs searchs if there's text
    if([searchBar.text length] > 0)
    {
        // dismissing the keyboard
        [searchBar resignFirstResponder];
        
        // initializing the ivar containing the search results
        _searchResults = [NSMutableArray arrayWithCapacity:10];
        
        // building the URL from the text user inputs in the search bar
        NSURL *url = [self urlWithSearchText:searchBar.text];
        //NSLog(@"URL '%@'", url);
        
        // json string containing the outcome of the search
        NSString *jsonString = [self performStoreRequestWithURL:url];
        //NSLog(@"Received json string '%@'", jsonString);
        
        // checking for errors in json string
        if(jsonString == nil)
        {
            [self showNetworkError];
            return;
        }
        
        // parsing json
        NSDictionary *dictionary = [self parseJson:jsonString];
        
        // checking for errors in json parsing
        if(dictionary == nil)
        {
            [self showNetworkError];
            return;
        }
        
        // we need to parse the dictionary as the iTunes store as different json data structures according to the product
        [self parseDictionary:dictionary];
        
        // alphabetical sort (using compareName on SearchResult class)
        [_searchResults sortUsingSelector:@selector(compareName:)];
        
        //NSLog(@"Dictionary '%@'", dictionary);
        
        [self.tableView reloadData];
    }

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
