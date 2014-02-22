//
//  DetailViewController.m
//  StoreSearch
//
//  Created by João Carreira on 22/02/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import "DetailViewController.h"
#import <QuartzCore/QuartzCore.h>

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
}


#pragma mark - Action methods

-(IBAction)close:(id)sender
{
    // this won't work because the view controller isn't shown modally
    //[self dismissViewControllerAnimated:YES completion:nil];

    // taking away the parent controller (SearhViewController)
    [self willMoveToParentViewController:nil];
    // removing the view from the screen
    [self.view removeFromSuperview];
    // disposing this view controller
    [self removeFromParentViewController];
}


#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // only returns YES when the touch is in the background
    return (touch.view == self.view);
}

@end
