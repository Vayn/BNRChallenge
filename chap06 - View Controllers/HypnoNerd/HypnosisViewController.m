//
//  HypnosisViewController.m
//  Hypnosister
//
//  Created by Vicent Tsai on 15/8/8.
//  Copyright © 2015年 Big Nerd Ranch. All rights reserved.
//

#import "HypnosisViewController.h"

@implementation HypnosisViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        // Set the tab bar item's title
        self.tabBarItem.title = @"Hypnotize";

        // Create a UIImage from a file
        // This will use Hypno@2x.png on retina display devices
        UIImage *i = [UIImage imageNamed:@"Hypno.png"];

        // Put that image on the tab bar item
        self.tabBarItem.image = i;
    }

    return self;
}

- (void)loadView
{
    // Create a view
    HypnosisView *mainView = [[HypnosisView alloc] init];

    // Set it as *the* view of this view controller
    self.backgroundView = mainView;
    self.view = self.backgroundView;
    [self addSegmentControl];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"HypnosisViewController loaded its view.");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addSegmentControl
{
    UISegmentedControl *colors = [[UISegmentedControl alloc] initWithItems:@[@"Red", @"Green", @"Blue"]];
    colors.frame = CGRectMake(80, 30, 160, 30);
    colors.momentary = YES;
    colors.backgroundColor = [UIColor whiteColor];

    self.colorChoice = colors;

    [self.colorChoice addTarget:self
                         action:@selector(chooseColor:)
               forControlEvents:UIControlEventValueChanged];

    [self.backgroundView addSubview:self.colorChoice];
}

- (void)chooseColor:(UISegmentedControl *)colorChoice
{
    NSString *controlSelected = [colorChoice titleForSegmentAtIndex:[colorChoice selectedSegmentIndex]];

    UIColor *colorSelected;

    if ([controlSelected isEqualToString:@"Red"]) {
        NSLog(@"Index selected: %@", colorSelected);
        colorSelected = [UIColor redColor];
    } else if ([controlSelected isEqualToString:@"Green"]) {
        NSLog(@"Index selected: %@", controlSelected);
        colorSelected = [UIColor greenColor];
    } else if ([controlSelected isEqualToString:@"Blue"]) {
        NSLog(@"Index selected: %@", controlSelected);
        colorSelected = [UIColor blueColor];
    }

    self.backgroundView.circleColor = colorSelected;
}

@end
