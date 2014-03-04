//
//  LandscapeViewController.m
//  StoreSearch
//
//  Created by João Carreira on 24/02/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import "LandscapeViewController.h"
#import "SearchResult.h"
#import <AFNetworking/UIButton+AFNetworking.h>
#import "Search.h"
#import "DetailViewController.h"

@interface LandscapeViewController ()<UIScrollViewDelegate>

@end

@implementation LandscapeViewController
{
    // ivar that detects the first time this view controller is load
    // (important as the math to calcule the buttons only has to be performed once)
    BOOL _firstTime;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _firstTime = YES;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // putting an image in the scrollview background
    self.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LandscapeBackground"]];
    
    // setting how big the "insides" of the scrollview will be
    //self.scrollView.contentSize = CGSizeMake(1000, self.scrollView.bounds.size.height);
    
    // hiding the page control when there's no search results
    self.pageControl.numberOfPages = 0;
}


// we can't use viewDidLoad to do the math on laying out the buttons as the view is not added to the view hierarchy until the end of viewDidLoad
// (i.e., at the end of viewDidLoad we don't know yet if we're in a 3.5 or 4-inch screen)
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // making sure that we only place the buttons once
    if(_firstTime)
    {
        _firstTime = NO;
        
        // showing a spinner when the search is performing
        if(self.search != nil)
        {
            if(self.search.isLoading)
            {
                [self showSpinner];
            }
            // no results
            else if([self.search.searchResults count] == 0)
            {
                [self showNothingFoundLabel];
            }
            else
            {
                [self tileButtons];
            }
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc
{
    //NSLog(@"DEALLOC '%@'", self);
    
    // cancel all image donwloading for buttons
    for(UIButton *button in self.scrollView.subviews)
    {
        [button cancelImageRequestOperation];
    }
}


#pragma mark - Instance methods


-(void)tileButtons
{
    // number of columns per page (5 in 3.5 inch device)
    int columnsPerPage = 5;
    
    // each item contains a button with the following dimensions for 3.5 inch device
    CGFloat itemWidth = 96.0f;
    CGFloat x = 0.0f;
    CGFloat extraSpace = 0.0f;
    
    // adjust values if it's a 4-inch
    // 3.5-inch is 480 (in landscape)
    // 4-inch is 568 (in landscape)
    // determining the width according to device
    CGFloat scrollViewWidth = self.scrollView.bounds.size.width;
    if(scrollViewWidth > 480.0f)
    {
        columnsPerPage = 6;
        itemWidth = 94.0f;
        x = 2.0f;
        // having 6 colunms in a 4-inch makes 568 / 6 not an even division (568 is the size of the screen) which means we need to leave 4 has extra space
        extraSpace = 4.0f;
    }
    
    // the item heigh is always 88
    const CGFloat itemHeight = 88.0f;
    // buttons will always be 82 x 82, no matter screen size
    const CGFloat buttonWidth = 82.0f;
    const CGFloat buttonHeight = 82.0f;
    const CGFloat marginHor = (itemWidth - buttonWidth) / 2.0f;
    const CGFloat marginVert = (itemHeight - buttonHeight) / 2.0f;
    
    // reseting before foreach loop
    int index = 0;
    int row = 0;
    int column = 0;
    
    // foreach loop to go through all search results
    for(SearchResult *searchResult in self.search.searchResults)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        // button image
        [self downloadImageForSearchResult:searchResult andPlaceOnButton:button];
        
        // background image
        [button setBackgroundImage:[UIImage imageNamed:@"LandscapeButton"] forState:UIControlStateNormal];
        
        // when making a button programatically we need to set it's frame
        button.frame = CGRectMake(x + marginHor, 20.0f + row * itemHeight + marginVert, buttonWidth, buttonHeight);
        
        // adding the button as a subview of the scrollview
        [self.scrollView addSubview:button];
        
        // afther the first 15 (on 3.5 inch) or 18 buttons (on 4 inch) we need to place the remaining buttons out of the visible range of the scroll view
        // (we can do this as long as we set the content size accordingly)
        index++;
        row++;
        
        // when we reach the bottom at row 3 we go up to the next column
        if(row == 3)
        {
            row = 0;
            column++;
            x += itemWidth;
            
            // when the column reaches the end of the screen we reset to 0 and take extra space into account
            if(column == columnsPerPage)
            {
                column = 0;
                x += extraSpace;
            }
        }
        
        // tagging the button and adding the appropriate action method
        // (first tag will start at 2000 for convenience)
        button.tag = 2000 + index;
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    int tilesPerPage = columnsPerPage * 3;
    
    // ceilf allows to round up because even if there's a remainder of just one search result we have to a make another extra page
    int numPages = ceilf([self.search.searchResults count]) / (float)tilesPerPage;
    
    self.scrollView.contentSize = CGSizeMake(numPages * scrollViewWidth, self.scrollView.bounds.size.height);
    
    // setting the number of dots to be displayed by page control
    self.pageControl.numberOfPages = numPages;
    self.pageControl.currentPage = 0;
}


// getting the artwork image on a button
-(void)downloadImageForSearchResult:(SearchResult *)searchResult andPlaceOnButton:(UIButton *)button
{
    NSURL *url = [NSURL URLWithString:searchResult.artworkURL60];
    
    // creating the NSMutableRequest (as it's done in UIButton+AFNetworking source code)
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    // the following setImageForState:withURLRequest:placeholderImage:success:failure has an ownership cycle
    // (inside the block we place the image on the button which means the block captures the button while
    // the button already owns the block)
    // this can lead to a memory leak so we'll use a weak pointer
    // (with this weak pointer the button still owns the block but the block doesn't own the button back)
    __weak UIButton *weakButton = button;
    
    
    
    // downloading the image
    [button setImageForState:UIControlStateNormal
              withURLRequest:request
            placeholderImage:nil
                     success:^(NSHTTPURLResponse *response, UIImage *image)
                            {
                            // scaling the image and placing it in the button (1.0 means not to treat it as a retina image)
                            UIImage *unscaledImage = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:image.imageOrientation];
        
                            [weakButton setImage:unscaledImage forState:UIControlStateNormal];
                            }
                     failure:^(NSError *error)
                        {
                            NSLog(@"failed: %@", error);
                        }];
}


-(void)showSpinner
{
    // creating the spinner
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    // putting it in the center of the screen
    spinner.center = CGPointMake(CGRectGetMidX(self.scrollView.bounds) + 0.5f, CGRectGetMidY(self.scrollView.bounds) + 0.5f);
    
    // tagging the spinner (to facilitate it's removal when needed)
    spinner.tag = 1000;
    
    // adding it to the screen
    [self.view addSubview:spinner];
    [spinner startAnimating];
}


-(void)searchResultsReceived
{
    [self hideSpinner];
    
    // when there's no results
    if([self.search.searchResults count] == 0)
    {
        [self showNothingFoundLabel];
    }
    // otherwise display buttons
    else
    {
        [self tileButtons];
    }
}


-(void)hideSpinner
{
    [[self.view viewWithTag:1000] removeFromSuperview];
}


-(void)showNothingFoundLabel
{
    // creating the label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = NSLocalizedString(@"Nothing found", @"nothing found label");
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    
    // resizing to optimal size
    [label sizeToFit];
    
    // centering the label
    CGRect rect = label.frame;
    rect.size.width = ceilf(rect.size.width / 2.0f) * 2.0f;
    rect.size.height = ceilf(rect.size.height / 2.0f) * 2.0f;
    label.frame = rect;
    label.center = CGPointMake(CGRectGetMidX(self.scrollView.bounds), CGRectGetMidY(self.scrollView.bounds));
    
    // adding the label to the view
    [self.view addSubview:label];
}


#pragma mark - Action methods

// there's no delegate that tells when the user taps the page control so we need to set an IBAction
-(IBAction)pageChanged:(UIPageControl *)sender
{
    // setting up a basic animation
    [UIView animateWithDuration:0.3
    delay:0
    options:UIViewAnimationOptionCurveEaseInOut
    animations:
     ^{
        // calculating the new offset when the user taps in the page control
        self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width * sender.currentPage, 0);
     }completion:nil];
}


// shows the popup when tapping a button
-(void)buttonPressed:(UIButton *)sender
{
    // creating the detail view controller
    DetailViewController *controller = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    
    // -2000 because in tileButtons: we started tagging at 2000 (and not 0)
    SearchResult *searchResult = self.search.searchResults[sender.tag - 2001];
    controller.searchResult = searchResult;
    
    // showing the controller in the screen
    [controller presentInParentViewController:self];
}


#pragma mark - ScrollView delegate


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat width = self.scrollView.bounds.size.width;
    
    // the contentOffset property determines how far the scroll view has been scrolled
    // if the contentOffset gets beyond halfway on the page the scroll view will flick to the next page
    int currentPage = (self.scrollView.contentOffset.x + width / 2.0f) / width;
    self.pageControl.currentPage = currentPage;
}

@end
