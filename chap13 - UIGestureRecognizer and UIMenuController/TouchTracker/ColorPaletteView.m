//
//  ColorPaletteView.m
//  TouchTracker
//
//  Created by Vicent Tsai on 15/8/23.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "ColorPaletteView.h"
#import "ColorView.h"

@implementation UIColor (Palette)

+ (UIColor *)indigoColor
{
    return [self colorWithRed:0.36 green:0.39 blue:0.78 alpha:1];
}

+ (UIColor *)lavenderIndigoColor
{
    return [self colorWithRed:0.58 green:0.33 blue:0.85 alpha:1];
}

+ (UIColor *)minskColor
{
    return [self colorWithRed:0.25 green:0.21 blue:0.42 alpha:1];
}

+ (UIColor *)calPolyPanomaGreenColor
{
    return [self colorWithRed:0.16 green:0.34 blue:0.15 alpha:1];
}

+ (UIColor *)fountainBlueColor
{
    return [self colorWithRed:0.39 green:0.65 blue:0.67 alpha:1];
}

+ (UIColor *)yellowGreenColor
{
    return [self colorWithRed:0.82 green:0.92 blue:0.55 alpha:1];
}

@end

@interface ColorPaletteView ()

@property (nonatomic, strong) UIView *transpanrentFader;
@property (nonatomic, strong) UIView *colorPalette;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) UIColor *selectedColor;

@property (nonatomic) CGRect hiddenFrame;
@property (nonatomic) CGRect visibleFrame;

@end

static const NSInteger numberOfColorsPerRow = 6;
static const NSInteger numberOfRowsOfColors = 1;
static const float animationDuration = 0.25;

@implementation ColorPaletteView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        self.colors = @[[UIColor indigoColor],
                    [UIColor lavenderIndigoColor],
                    [UIColor minskColor],
                    [UIColor calPolyPanomaGreenColor],
                    [UIColor fountainBlueColor],
                    [UIColor yellowColor]];

        CGRect screenRect = [[UIScreen mainScreen] bounds];

        self.transpanrentFader = [[UIView alloc] initWithFrame:screenRect];
        self.transpanrentFader.backgroundColor = [UIColor whiteColor];
        self.transpanrentFader.alpha = 0.0f;
        [self addSubview:self.transpanrentFader];

        const CGFloat colorLength = CGRectGetWidth(screenRect) / numberOfColorsPerRow;

        CGFloat beginTopOfPanelY = CGRectGetHeight(screenRect);
        CGFloat endTopOfPanelY = beginTopOfPanelY - numberOfRowsOfColors * colorLength;
        CGFloat panelWidth = CGRectGetWidth(screenRect);
        CGFloat panelHeight = numberOfRowsOfColors * colorLength;

        self.hiddenFrame = CGRectMake(0, beginTopOfPanelY, panelWidth, panelHeight);
        self.visibleFrame = CGRectMake(0, endTopOfPanelY, panelWidth, panelHeight);

        self.colorPalette = [[UIView alloc] initWithFrame:self.hiddenFrame];

        for (NSInteger row = 0; row < numberOfRowsOfColors; row++) {
            for (NSInteger column = 0; column < numberOfColorsPerRow; column++) {
                CGRect frame = CGRectMake(column * colorLength, row * colorLength, colorLength, colorLength);
                ColorView *colorView = [[ColorView alloc] initWithFrame:frame];
                colorView.backgroundColor = self.colors[column];

                [self.colorPalette addSubview:colorView];
            }
        }

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(tap:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        tap.cancelsTouchesInView = YES;
        [self addGestureRecognizer:tap];

        [self addSubview:_colorPalette];

        [UIView animateWithDuration:animationDuration
                              delay:0.0
             usingSpringWithDamping:1
              initialSpringVelocity:0.5
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.colorPalette.frame = self.visibleFrame;
                             self.transpanrentFader.alpha = 0.6;
                         }
                         completion:nil];
    }

    return self;
}

- (void)tap:(UIGestureRecognizer *)gr
{
    CGPoint tappedPoint = [gr locationInView:self];
    NSLog(@"%@", NSStringFromCGPoint(tappedPoint));

    UIView *tappedView = [self hitTest:tappedPoint withEvent:nil];
    if ([tappedView isKindOfClass:ColorView.class]) {
        self.selectedColor = ((ColorView *)tappedView).backgroundColor;
    }

    [self dismiss];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismiss];
}

- (void)dismiss
{
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.colorPalette.frame = self.hiddenFrame;
                         self.transpanrentFader.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         if (self.completion) {
                             self.completion(self.selectedColor);
                         }
                         [self removeFromSuperview];
                     }];
}

@end
