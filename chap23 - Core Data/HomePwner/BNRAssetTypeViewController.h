//
//  BNRAssetTypeViewController.h
//  HomePwner
//
//  Created by Vicent Tsai on 15/9/13.
//  Copyright © 2015年 Big Nerd Ranch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BNRItem;

@interface BNRAssetTypeViewController : UITableViewController

@property (nonatomic, strong) BNRItem *item;
@property (nonatomic, copy) void (^dismissBlock)(void);

@end
