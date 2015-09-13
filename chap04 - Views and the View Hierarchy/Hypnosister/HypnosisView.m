//
//  HypnosisView.m
//  Hypnosister
//
//  Created by Vicent Tsai on 15/8/7.
//  Copyright © 2015年 Big Nerd Ranch. All rights reserved.
//

#import "HypnosisView.h"

@implementation HypnosisView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];

    if (self) {
        // All HypnosisViews start with a clear background color
        self.backgroundColor = [UIColor clearColor];
    }

    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGRect bounds = self.bounds;

    // Figure out the center of the bounds rectangle
    CGPoint center;
    center.x = bounds.origin.x + bounds.size.width / 2.0;
    center.y = bounds.origin.y + bounds.size.height / 2.0;

    /*
    // The circle will be the largest that will fit in the view
    float radius = (MIN(bounds.size.width, bounds.size.height) / 2.0);
     */

    // The largest circle will circumscribe the view
    float maxRadius = hypot(bounds.size.width, bounds.size.height) / 2.0;

    UIBezierPath *path = [[UIBezierPath alloc] init];

    for (float currentRadius = maxRadius; currentRadius > 0; currentRadius -= 20) {
        [path moveToPoint:CGPointMake(center.x + currentRadius, center.y)];

        [path addArcWithCenter:center
                        radius:currentRadius
                    startAngle:0.0
                      endAngle:M_PI * 2.0
                     clockwise:YES];
    }

    // Configure the drawing color to light gray
    [[UIColor lightGrayColor] setStroke];

    // Configure line width to 10 points
    path.lineWidth = 10;

    // Draw the line
    [path stroke];

    // Bronze & Gold Challenge

    // Get current context
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);

    // Allocate and initiate myPath, the instance of UIBerzierPath class, to use for the path of clipping area.
    UIBezierPath *myPath = [[UIBezierPath alloc] init];

    // Make clipping area as triangle by adding some line to myPath.
    [myPath moveToPoint:CGPointMake(bounds.origin.x + bounds.size.width / 2.0,
                                    bounds.origin.y + bounds.size.height / 6.0)];

    [myPath addLineToPoint:CGPointMake(bounds.origin.x + bounds.size.width / 6.0,
                                       bounds.origin.y + bounds.size.height / 6.0 * 5.0)];

    [myPath addLineToPoint:CGPointMake(bounds.origin.x + bounds.size.width / 6.0 * 5,
                                       bounds.origin.y + bounds.size.height / 6.0 * 5.0)];

    // Intersect myPath and current graphic context and make resulting shape the current clipping path.
    [myPath addClip];

    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        0.0, 1.0, 0.0, 1.0, // Start color is green
        1.0, 1.0, 0.0, 1.0  // End color is yellow
    };

    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, 2);

    CGPoint startPoint = bounds.origin, endPoint = bounds.origin;
    endPoint.y+=bounds.size.height/2;
    CGContextDrawLinearGradient(currentContext, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorspace);

    // Restore current context
    CGContextRestoreGState(currentContext);

    UIImage *logoImage = [UIImage imageNamed:@"transparency.png"];

    // CGRect logoRect for logo image frame
    CGRect logoRect;
    logoRect.origin.x = bounds.origin.x + bounds.size.width / 4.0;
    logoRect.origin.y = bounds.origin.y + bounds.size.height / 4.0;
    logoRect.size.width = bounds.size.width / 2.0;
    logoRect.size.height = bounds.size.height / 2.0;

    // Logo image with shadow
    CGSize offset = CGSizeMake(4, 3);
    CGColorRef color = [[UIColor darkGrayColor] CGColor];
    CGContextSetShadowWithColor(currentContext, offset, 2.0, color);

    [logoImage drawInRect:logoRect];

}

@end
