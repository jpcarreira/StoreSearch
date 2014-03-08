//
//  AppDelegate.m
//  StoreSearch
//
//  Created by João Carreira on 19/02/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import "AppDelegate.h"
#import "SearchViewController.h"
#import "DetailViewController.h"

@implementation AppDelegate


// custom appearance
-(void)customizeAppearance
{
    // UISearchBar
    UIColor *barTintColor = [UIColor colorWithRed:20.0/255.0f green:160.0/255.0f blue:160.0/255.0f alpha:1.0f];
    [[UISearchBar appearance] setBarTintColor:barTintColor];
    
    // window
    self.window.tintColor = [UIColor colorWithRed:10.0/255.0f green:80.0/255.0f blue:80.0/255.0f alpha:1.0f];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // creating a UIWindow object
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // customizing appearance (this method call must be exactly after creating the UIWindow object)
    [self customizeAppearance];
    
    // assigning a root view controller to the window
    self.searchViewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
    
    // if we're in an iPad we'll use the split view controller
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.splitViewController = [[UISplitViewController alloc] init];
        
        DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
        
        // a navigation controller is needed for the detail view controller
        UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
        
        self.splitViewController.delegate = detailViewController;
        
        // in the array, 0 is the master pane and 1 is the detail pane
        self.splitViewController.viewControllers = @[self.searchViewController, detailNavigationController];
        
        self.window.rootViewController = self.splitViewController;
    }
    // else it's an iphone or ipod touch
    else
    {
        self.window.rootViewController = self.searchViewController;
    }
    
    // making the window visible
    [self.window makeKeyAndVisible];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
