//
//  LandscapeViewController.h
//  StoreSearch
//
//  Created by João Carreira on 24/02/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LandscapeViewController : UIViewController

@property(nonatomic, strong) NSArray *searchResults;

@property(nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property(nonatomic, weak) IBOutlet UIPageControl *pageControl;

@end
