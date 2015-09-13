//
//  PopoverBackgroundView.m
//  Homepwner
//
//  Created by Vicent Tsai on 15/8/25.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "PopoverBackgroundView.h"

#define kArrowBase 30.0f
#define kArrowHeight 20.0f
#define kBorderInset 0.0f

@interface PopoverBackgroundView ()

@property (nonatomic, strong) UIImageView *arrowImageView;

- (UIImage *)drawArrowImage:(CGSize)size;

@end

@implementation PopoverBackgroundView

/*
 * The arrowBase method determines the width of the arrow’s base,
 * while the arrowHeight method determines the height of the arrow.
 * The contentViewInsets method indicates how far from the edge of
 * the background to display the content.
 */

@synthesize arrowOffset = _arrowOffset;
@synthesize arrowDirection = _arrowDirection;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        self.backgroundColor = [UIColor clearColor];

        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.arrowImageView = arrowImageView;
        [self addSubview:self.arrowImageView];

        //self.arrowDirection = UIPopoverArrowDirectionAny;
        self.arrowOffset = 20.0;
    }

    return self;
}

+ (CGFloat)arrowBase
{
    return kArrowBase;
}

+ (CGFloat)arrowHeight
{
    return kArrowHeight;
}

+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsMake(kBorderInset, kBorderInset, kBorderInset, kBorderInset);
}

/*
 * The wantsDefaultContentAppearance method determines whether the default inset
 * shadows and rounded corners are displayed in the popover. By returning NO,
 * the popover background view will no longer show the default shadows and rounded
 * corners, allowing you to implement your own. Add the following code to override the method.
 */
+ (BOOL)wantsDefaultContentAppearance
{
    return NO;
}

/*
 * Each time the bounds of the popover background view subclass changes,
 * the frame of the arrow needs to be recalculated. We can accomplish this
 * by overriding _layoutSubviews_.
 */
- (void)layoutSubviews
{
    [super layoutSubviews];

    CGSize arrowSize = CGSizeMake([[self class] arrowBase], [[self class] arrowHeight]);
    self.arrowImageView.image = [self drawArrowImage:arrowSize];
    self.arrowImageView.frame = CGRectMake(self.arrowOffset,
                                           (self.bounds.size.height - arrowSize.height),
                                           arrowSize.width,
                                           arrowSize.height);
}

- (UIImage *)drawArrowImage:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor clearColor] setFill];
    CGContextFillRect(ctx, CGRectMake(0.0, 0.0, size.width, size.height));

    CGMutablePathRef arrowPath = CGPathCreateMutable();

    /* // Standard triangle
     CGPathMoveToPoint(arrowPath, NULL, (size.width / 2.0), 0.0);
     CGPathAddLineToPoint(arrowPath, NULL, size.width, size.height);
     CGPathAddLineToPoint(arrowPath, NULL, 0.0, size.height);
     */

    // Upside-down triangle
    CGPathMoveToPoint(arrowPath, NULL, 0.0, 0.0);
    CGPathAddLineToPoint(arrowPath, NULL, size.width, 0.0);
    CGPathAddLineToPoint(arrowPath, NULL, (size.width / 2.0), size.height);

    CGPathCloseSubpath(arrowPath);
    CGContextAddPath(ctx, arrowPath);

    /*
    UIColor *fillColor = [UIColor yellowColor];
    CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
    CGContextDrawPath(ctx, kCGPathFill);
     */

    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        0.0, 1.0, 0.0, 1.0, // Start color is green
        1.0, 1.0, 0.0, 1.0  // End color is yellow
    };

    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, 2);
    CGColorSpaceRelease(colorspace), colorspace = NULL;

    CGContextClip(ctx);
    CGRect boundingBox = CGPathGetBoundingBox(arrowPath);
    CGPoint gradientStart = CGPointMake(0, CGRectGetMinY(boundingBox));
    CGPoint gradientEnd = CGPointMake(0, CGRectGetMaxY(boundingBox));

    CGContextDrawLinearGradient(ctx, gradient, gradientStart, gradientEnd, 0);
    CGGradientRelease(gradient), gradient = NULL;

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
