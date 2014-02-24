//
//  DetailViewController.m
//  StoreSearch
//
//  Created by João Carreira on 22/02/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import "DetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SearchResult.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "GradientView.h"

// this class doesn't need a delegate protocol because there's nothing to communicate back to the Search View Controller
@interface DetailViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UIView *popUpView;
@property (nonatomic, weak) IBOutlet UIImageView *artworkImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *artistNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *kindLabel;
@property (nonatomic, weak) IBOutlet UILabel *genreLabel;
@property (nonatomic, weak) IBOutlet UIButton *priceButton;

@end

@implementation DetailViewController
{
    // ivar to hold the gradient view object
    GradientView *_gradientView;
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
    
    // setting up a clear color to enhance the circular grandient from GradientView.m
    self.view.backgroundColor = [UIColor clearColor];
    
    // "rounding" the edges of the popup
    self.popUpView.layer.cornerRadius = 10.0f;
    
    // "stretching" the button
    UIImage *image = [[UIImage imageNamed:@"PriceButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    
    // "paiting" the button image with the same tint color
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [self.priceButton setBackgroundImage:image forState:UIControlStateNormal];
    
    // applying a tint color to the view (we could also apply to individual object in this view)
    self.view.tintColor = [UIColor colorWithRed:20/255.0f green:160/255.0f blue:160/255.0f alpha:1.0f];
    
    // enabling a gesture recognizer to dismiss the popup window
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
    gestureRecognizer.cancelsTouchesInView = NO;
    gestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    // setting up the UI
    if(self.searchResult != nil)
    {
        [self updateUI];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc
{
    // just to make sure this view controller is properly dismissed when pressing close button
    //NSLog(@"DetailViewController dealloc %@", self);
    
    // canceling image download in case user closes the popup
    [self.artworkImageView cancelImageRequestOperation];
    
}


#pragma mark - Instance methods

-(void)updateUI
{
    // setting up the labels
    self.nameLabel.text = self.searchResult.name;
    
    NSString *artistName = self.searchResult.artistName;
    if(artistName == nil)
    {
        artistName = @"Unknown";
    }
    
    self.artistNameLabel.text = artistName;
    self.kindLabel.text = [self.searchResult kindForDisplay];
    self.genreLabel.text = self.searchResult.genre;
    
    // setting up the price button
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setCurrencyCode:self.searchResult.currency];
    
    NSString *priceText;
    if([self.searchResult.price floatValue] == 0.0f)
    {
        priceText = @"Free";
    }
    else
    {
        priceText = [formatter stringFromNumber:self.searchResult.price];
    }
    
    [self.priceButton setTitle:priceText forState:UIControlStateNormal];
    
    // loading artwork
    [self.artworkImageView setImageWithURL:[NSURL URLWithString:self.searchResult.artworkURL100]];
}


// this method is responsible to show this viewcontroller as a child in another viewcontroller
-(void)presentInParentViewController:(UIViewController *)parentViewController
{
    // initializing the gradient view and adding as a subview of SearchViewController
    _gradientView = [[GradientView alloc] initWithFrame:parentViewController.view.bounds];
    [parentViewController.view addSubview:_gradientView];
    
    // note that the gradient view was added to SearchViewController before we added DetailsViewController
    // so the gradient view is still below the popup (as intended) but not affected by the animation
    
    // 1 - standard parent-child relationships
    // resizing the DetailViewController's view size to the same as the SearchViewController
    self.view.frame = parentViewController.view.bounds;
    // add the new view controller as a subview
    [parentViewController.view addSubview:self.view];
    // tell the parent view controller that DetailsViewController is managing the screen
    [parentViewController addChildViewController:self];
    
    
    // 2 - animation of the popup
    // creating an animation that works on the view's transforma.scale attributes
    // (i.e., we're animating the size of the view)
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    // setting the animation's delegate so that this view controller knows when the animation stops
    // (so that we call the didMoveToParentViewController:)
    bounceAnimation.delegate = self;
    
    // the animation has several keyframes and we set to 0.4 the time it takes to proceed from one keyframe to the other
    bounceAnimation.duration = 0.4;
    
    // specifying how much bigger (or smaller) the view will be over time
    // (in this case, scaling to 70% of normal size, followed by 120%, 90% and 100% (thus, the last one restores original size)
    bounceAnimation.values = @[@0.7, @1.2, @0.9, @1.0];
    
    // specifying a duration for each keyframe
    // (this values are fractions of the initial duration, thus the second one lasts 0.4*0.334)
    bounceAnimation.keyTimes = @[@0.0, @0.334, @0.666, @1.0];
    
    // timing function to go from one keyframe to another
    bounceAnimation.timingFunctions = @[
                                    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    // adding the animation to the view's layer
    [self.view.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
    
    
    // 3 - animation of the gradient view (simple "fade-in")
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = @0.0f;
    fadeAnimation.toValue = @1.0f;
    fadeAnimation.duration = 0.2f;
    [_gradientView.layer addAnimation:fadeAnimation forKey:@"fadeAnimation"];
    
}


-(void)dismissFromParentViewController
{
    // taking away the parent controller (SearhViewController)
    [self willMoveToParentViewController:nil];
    // removing the view from the screen
    [self.view removeFromSuperview];
    // disposing this view controller
    [self removeFromParentViewController];
    
    // removing the gradient view when the popup is closed
    [_gradientView removeFromSuperview];
}


#pragma mark - Action methods

-(IBAction)close:(id)sender
{
    [self dismissFromParentViewController];
}

-(IBAction)openInStore:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.searchResult.storeURL]];
    //NSLog(@"url = '%@'", self.searchResult.storeURL);
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // only returns YES when the touch is in the background
    return (touch.view == self.view);
}


# pragma mark - CAAnimation delegates
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    // tell DetailsViewController that this controller is it's parent
    [self didMoveToParentViewController:self.parentViewController];
}

@end
