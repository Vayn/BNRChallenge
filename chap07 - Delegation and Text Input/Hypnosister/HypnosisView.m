//
//  HypnosisView.m
//  Hypnosister
//
//  Created by Vicent Tsai on 15/8/7.
//  Copyright © 2015年 Big Nerd Ranch. All rights reserved.
//

#import "HypnosisView.h"

@interface HypnosisView ()

@property (strong, nonatomic) UIColor *circleColor;

@end

@implementation HypnosisView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];

    if (self) {
        // All HypnosisViews start with a clear background color
        self.backgroundColor = [UIColor clearColor];
        self.circleColor = [UIColor lightGrayColor];    
    }

    return self;
}

- (void)setCircleColor:(UIColor *)circleColor
{
    _circleColor = circleColor;
    [self setNeedsDisplay];
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

    /*
    // Configure the drawing color to light gray
    [[UIColor lightGrayColor] setStroke];
     */
    [self.circleColor setStroke];

    // Configure line width to 10 points
    path.lineWidth = 10;

    // Draw the line
    [path stroke];
}

- (UIColor *)makeRandomColor
{
    // Get 3 random numbers between 0 and 1
    CGFloat red = (rand() % 100) / 100.0;
    CGFloat green = (rand() % 100) / 100.0;
    CGFloat blue = (rand() % 100) / 100.0;
    NSLog(@"Random color: R=%f, G=%f, B=%f", red, green, blue);

    UIColor *randomColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    return randomColor;
}

// When a finger touches the screen
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.circleColor = [self makeRandomColor];
}

@end
