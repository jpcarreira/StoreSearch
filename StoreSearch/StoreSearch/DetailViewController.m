//
//  DetailViewController.m
//  StoreSearch
//
//  Created by João Carreira on 22/02/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import "DetailViewController.h"

// this class doesn't need a delegate protocol because there's nothing to communicate back to the Search View Controller
@interface DetailViewController ()

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
    // Do any additional setup after loading the view from its nib.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc
{
    // just to make sure this view controller is properly dismissed when pressing close button
    NSLog(@"DetailViewController dealloc %@", self);
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

@end
