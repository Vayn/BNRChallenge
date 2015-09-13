//
//  AppDelegate.m
//  Homepwner
//
//  Created by Vicent Tsai on 15/8/15.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "AppDelegate.h"
#import "ItemsTableViewController.h"
#import "ItemStore.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%@", NSStringFromSelector(_cmd));

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Create a ItemsViewController
    ItemsTableViewController *itemsViewController = [[ItemsTableViewController alloc] init];

    // Create an instance of a UINavigationController
    // its stack contains only itemsViewController
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:itemsViewController];

    // Place ItemsViewController's table view in the window hierarchy
    self.window.rootViewController = navController;

    self.window.backgroundColor = [UIColor clearColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"%@", NSStringFromSelector(_cmd));

    BOOL success = [[ItemStore sharedStore] saveChanges];
    if (success) {
        NSLog(@"Saved all of the Items");
    } else {
        NSLog(@"Could not save any of the Items");
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

@end
