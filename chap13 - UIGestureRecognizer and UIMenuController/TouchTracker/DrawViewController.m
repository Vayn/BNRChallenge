//
//  DrawViewController.m
//  TouchTracker
//
//  Created by Vicent Tsai on 15/8/20.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "DrawViewController.h"
#import "DrawView.h"

@interface DrawViewController ()

@end

@implementation DrawViewController

- (void)loadView
{
    self.view = [[DrawView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
