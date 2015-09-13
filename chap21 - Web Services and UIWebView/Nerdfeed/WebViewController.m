//
//  WebViewController.m
//  Nerdfeed
//
//  Created by Vicent Tsai on 15/9/11.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIBarButtonItem *backButton;
@property (nonatomic, strong) UIBarButtonItem *forwardButton;

@end

@implementation WebViewController

- (void)loadView
{
    UIWebView *webView = [[UIWebView alloc] init];
    webView.scalesPageToFit = YES;
    webView.delegate = self;

    CGRect frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 44,
                              [[UIScreen mainScreen] bounds].size.width, 44);
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:frame];

    self.backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                                                                 target:self
                                                                 action:@selector(goBack:)];
    self.backButton.enabled = NO;

    self.forwardButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
                                                                       target:self
                                                                       action:@selector(goForward:)];
    self.forwardButton.enabled = NO;

    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];

    NSArray *buttons = [NSArray arrayWithObjects:self.backButton, flexibleSpace, self.forwardButton, nil];
    [toolbar setItems:buttons animated:NO];

    [webView addSubview:toolbar];
    self.navigationController.toolbarHidden = NO;

    self.view = webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setURL:(NSURL *)URL
{
    _URL = URL;

    if (_URL) {
        NSURLRequest *req = [NSURLRequest requestWithURL:_URL];
        [(UIWebView *)self.view loadRequest:req];
    }
}

- (void)goBack:(id)sender
{
    if ([(UIWebView *)self.view canGoBack]) {
        [(UIWebView *)self.view goBack];
    }
}

- (void)goForward:(id)sender
{
    if ([(UIWebView *)self.view canGoForward]) {
        [(UIWebView *)self.view goForward];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.backButton setEnabled:[webView canGoBack]];
    [self.forwardButton setEnabled:[webView canGoForward]];
}

@end
