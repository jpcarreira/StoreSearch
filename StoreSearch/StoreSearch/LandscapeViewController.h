//
//  LandscapeViewController.h
//  StoreSearch
//
//  Created by João Carreira on 24/02/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Search;

@interface LandscapeViewController : UIViewController

@property(nonatomic, strong) Search *search;

@property(nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property(nonatomic, weak) IBOutlet UIPageControl *pageControl;

@end
