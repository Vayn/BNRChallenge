//
//  HypnosisViewController.h
//  Hypnosister
//
//  Created by Vicent Tsai on 15/8/8.
//  Copyright © 2015年 Big Nerd Ranch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HypnosisView.h"

@interface HypnosisViewController : UIViewController

@property (nonatomic, weak) HypnosisView *backgroundView;
@property (nonatomic, weak) UISegmentedControl *colorChoice;

- (void)addSegmentControl;
- (void)chooseColor:(UISegmentedControl *)colorChoice;

@end
