//
//  ImageViewController.m
//  Homepwner
//
//  Created by Vicent Tsai on 15/9/10.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ImageViewController

- (void)loadView
{
    /* Gold */
    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    self.imageView.contentMode = UIViewContentModeCenter;

    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.contentSize = self.imageView.bounds.size;
    scrollView.scrollEnabled = NO;
    scrollView.minimumZoomScale = 0.5;
    scrollView.maximumZoomScale = 2.0;
    scrollView.delegate = self;

    [scrollView addSubview:self.imageView];

    self.view = scrollView;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    /* Gold */
    UIScrollView *scrollView = (UIScrollView *)self.view;
    scrollView.contentOffset = CGPointMake(self.imageView.bounds.size.width / 2 - scrollView.bounds.size.width / 2,
                                           self.imageView.bounds.size.height / 2 - scrollView.bounds.size.height / 2);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* Gold */
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

/* Gold */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UIView *view = self.imageView;
    CGFloat ratio = MIN(view.bounds.size.width, view.bounds.size.height) * scrollView.zoomScale;

    if (ratio < scrollView.bounds.size.height) {
        CGPoint offset;

        offset.x = (view.bounds.size.width * scrollView.zoomScale - scrollView.bounds.size.width) / 2;
        offset.y = (view.bounds.size.height * scrollView.zoomScale - scrollView.bounds.size.height) / 2;

        scrollView.contentOffset = offset;
    }

}

@end
