//
//  HypnosisViewController.m
//  Hypnosister
//
//  Created by Vicent Tsai on 15/8/8.
//  Copyright © 2015年 Big Nerd Ranch. All rights reserved.
//

#import "HypnosisViewController.h"
#import "HypnosisView.h"
#import "TriangleView.h"

@interface HypnosisViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) HypnosisView *hypnosisView;
@property (nonatomic, strong) TriangleView *triangleView;

@end

@implementation HypnosisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // Create CGRects for frames
    CGRect screenRect = self.view.bounds;
    CGRect bigRect = screenRect;
    bigRect.size.width *= 2;
    //bigRect.size.height *= 2;

    // Create a screen-sized scroll view and add it to the window
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:screenRect];
    scrollView.pagingEnabled = YES;
    [self.view addSubview:scrollView];

    /*
    // Create a super-sized hypnosis view and add it to the scroll view
    self.hypnosisView = [[HypnosisView alloc] initWithFrame:bigRect];
    [scrollView addSubview:self.hypnosisView];
     */
    // Create a screen-sized hypnosis view and add it to the scroll view
    self.hypnosisView = [[HypnosisView alloc] initWithFrame:screenRect];
    [scrollView addSubview:self.hypnosisView];

    // CGRect logoRect for logo image frame
    CGRect logoRect;
    logoRect.origin.x = screenRect.origin.x + screenRect.size.width / 6.0;
    logoRect.origin.y = screenRect.origin.y + screenRect.size.height / 4.0;
    logoRect.size.width = screenRect.size.width / 1.5;
    logoRect.size.height = screenRect.size.height / 2.0;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:logoRect];

    UIImage *logoImage = [UIImage imageNamed:@"transparency.png"];
    imageView.image = logoImage;

    // Logo image with shadow
    CGSize offset = CGSizeMake(4, 3);
    CGColorRef color = [[UIColor darkGrayColor] CGColor];
    [[imageView layer] setShadowOffset:offset];
    [[imageView layer] setShadowColor:color];
    [[imageView layer] setShadowOpacity:0.50];

    // Logo image with motion effect
    UIInterpolatingMotionEffect *hMotionEffect;
    hMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                                    type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    hMotionEffect.minimumRelativeValue = @(-25);
    hMotionEffect.maximumRelativeValue = @(25);

    UIInterpolatingMotionEffect *vMotionEffect;
    vMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                                    type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    vMotionEffect.minimumRelativeValue = @(-25);
    vMotionEffect.maximumRelativeValue = @(25);

    UIMotionEffectGroup *mGroup = [UIMotionEffectGroup new];
    mGroup.motionEffects = @[hMotionEffect, vMotionEffect];
    [imageView addMotionEffect:mGroup];

    [self.hypnosisView addSubview:imageView];

    // SILVER CHALLENGE: set the UIScrollView instance minimum and maximum zoom scale
    scrollView.minimumZoomScale = 1;
    scrollView.maximumZoomScale = 5;
    scrollView.delegate = self;
    self.hypnosisView.center = scrollView.center;

    /*
    // Add a second screen-sized hypnosis view just off screen to the right
    screenRect.origin.x += screenRect.size.width;
    self.triangleView = [[TriangleView alloc] initWithFrame:screenRect];
    [scrollView addSubview:self.triangleView];
     */

    // Tell the scroll view how big its content area is
    scrollView.contentSize = bigRect.size;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    NSLog(@"viewForZoomingInScrollView works!");
    return self.hypnosisView;
}

@end
