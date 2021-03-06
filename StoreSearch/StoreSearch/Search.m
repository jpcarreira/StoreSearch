//
//  Search.m
//  StoreSearch
//
//  Created by João Carreira on 02/03/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import "Search.h"
#import "SearchResult.h"
#import <AFNetworking/AFNetworking.h>

// class variable (i.e., global variable)
// (a class variable lasts even when the object is deleted)
// static means this global variable is only visible to this class
static NSOperationQueue *queue = nil;

// class extension
// in the .h the searchResults is a readonly property, but here we want this property to be readwrite
// (this way, this property will be readonly to outside objects but fully accessible within the class)
@interface Search()
@property(nonatomic, readwrite, strong) NSMutableArray *searchResults;
@end


@implementation Search

#pragma mark - standard methods

-(void)dealloc
{
    NSLog(@"DEALLOC %@", self);
}


#pragma mark - Instance Methods

// class method to initialize the class variable
+(void)initialize
{
    if(self == [Search class])
    {
        queue = [[NSOperationQueue alloc] init];
    }
}

-(void)performSearchForText:(NSString *)text category:(NSInteger)category completion:(SearchBlock)block
{
   if([text length] > 0)
   {
       [queue cancelAllOperations];
       
       self.isLoading = YES;
       self.searchResults = [NSMutableArray arrayWithCapacity:10];
       
       NSURL *url = [self urlWithSearchText:text category:category];
       NSURLRequest *request = [NSURLRequest requestWithURL:url];
       
       AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
       operation.responseSerializer = [AFJSONResponseSerializer serializer];
       
       [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
           [self parseDictionary:responseObject];
           [self.searchResults sortUsingSelector:@selector(compareName:)];
           self.isLoading = NO;
           block(YES);
           NSLog(@"sucess...");
       }failure:^(AFHTTPRequestOperation *operation, NSError *error){
           self.isLoading = NO;
           block(NO);
           NSLog(@"failed");
       }];
       
       [queue addOperation:operation];
   }
}


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
    
    // sending information about the user's language and regional settings
    NSLocale *locale = [NSLocale autoupdatingCurrentLocale];
    NSString *language = [locale localeIdentifier];
    NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    
    // encoding URL from search text (UTF8)
    NSString *escapedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"http://itunes.apple.com/search?term=%@&limit=200&entity=%@&lang=%@&country=%@", escapedSearchText, categoryName, language, countryCode];
    
    NSLog(@"URL = %@", urlString);
    
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
            [self.searchResults addObject:searchResult];
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


@end
