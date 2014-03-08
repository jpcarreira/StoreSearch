//
//  DetailViewController.h
//  StoreSearch
//
//  Created by João Carreira on 22/02/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchResult;

// enum for dismiss animation
typedef NS_ENUM(NSUInteger, DetailViewControllerAnimationType)
{
    DetailViewControllerAnimationTypeSlide,
    DetailViewControllerAnimationTypeFade
};

@interface DetailViewController : UIViewController<UISplitViewControllerDelegate>

// the SearchResult object should be put in this public interface as there is another object, the SearchViewController,
// will need to see it to acess and modify it (unlike the IBOutlets)
@property (nonatomic, strong) SearchResult *searchResult;

-(void)presentInParentViewController:(UIViewController *)parentViewController;
-(void)dismissFromParentViewControllerWithAnimationType:(DetailViewControllerAnimationType)animationType;

@end
