//
//  DrawView.m
//  TouchTracker
//
//  Created by Vicent Tsai on 15/8/20.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "DrawView.h"
#import "Line.h"

#pragma mark - Constans
typedef NS_ENUM(char, lineType)
{
    straight,
    arc
};

#pragma mark - C helper functions

// declarations
double AngleBetweenTwoPoints(CGPoint point1, CGPoint point2);
int QuadrantForAngle(CGFloat degrees);
NSString *DocsPath(void);

// Retrieve iOS docs path
NSString *DocsPath()
{
    NSArray *pathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, // Foundation function
                                                            NSUserDomainMask,
                                                            YES);

    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:pathList[0]
                                             withIntermediateDirectories:YES
                                                              attributes:nil
                                                                   error:NULL];
    if(!success) {
        NSLog(@"Error: Create folder failed %@", pathList);
    }

    NSString *docspath = [pathList[0] stringByAppendingPathComponent:@"lines.plist"];

    return docspath;
}

// Calculate line angle, using atan2(point, point) way
double AngleBetweenTwoPoints(CGPoint point1, CGPoint point2)
{
    // Calculate the distance/vectors between both points
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;

    // Calculate angle
    CGFloat radian = atan2f(dy, dx); // bearing in radians

    // Convert to degrees
    CGFloat angle = radian * 180 / M_PI;

    //int quadrant = QuadrantForAngle(angle);

    //NSLog(@" %.2f degrees | %.2f radians : Quadrant %d ", angle, radian, quadrant);

    return angle;
}

int QuadrantForAngle(CGFloat degrees)
{
    // Convert angle to radians
    CGFloat angleRadian = degrees * M_PI / 180.0;

    // Determine quadrant for angle
    int quadrant = 0;
    // Output angle (in degrees) and quadrant
    if (angleRadian >= 0 && angleRadian < M_PI/2) {
        quadrant += 1;
        //NSLog(@"%.2f degrees: 1st Quadrant", angleRadian);
    }
    else if (angleRadian >= M_PI/2 && angleRadian < M_PI) {
        quadrant += 2;
        //NSLog(@" %.2f degrees : 2nd Quadrant", angleRadian);
    }
    else if (angleRadian >= -M_PI && angleRadian < -M_PI/2) {
        quadrant += 3;
        //NSLog(@" %.2f degrees : 3rd Quadrant", angleRadian);
    }
    else if (angleRadian >= -M_PI/2 && angleRadian < 0) {
        quadrant += 4;
        //NSLog(@" %.2f degrees : 4th Quadrant", angleRadian);
    }

    return quadrant;
}

#

@interface DrawView ()

//@property (nonatomic, strong) Line *currentLine;
@property (nonatomic, strong) NSMutableDictionary *linesInProgress;
@property (nonatomic, strong) NSMutableArray *finishedLines;
@property (nonatomic, strong) NSMutableArray *finishedCircles;
@property (nonatomic) lineType lineType;

@end

@implementation DrawView

#pragma mark - view init
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        self.linesInProgress = [[NSMutableDictionary alloc] init];
        self.finishedLines = [[NSMutableArray alloc] init];
        self.finishedCircles = [[NSMutableArray alloc] init];

        // Load saved lines if they exist
        NSMutableArray *plist = [NSKeyedUnarchiver unarchiveObjectWithFile:DocsPath()];
        //NSLog(@"Type of plist: %@", [plist class]);
        
        if (plist) {
            NSLog(@"Saved lines found, loading...\n%@", plist);
            self.finishedLines = plist;
        } else {
            NSLog(@"No saved lines found...");
        }

        self.backgroundColor = [UIColor grayColor];
        self.multipleTouchEnabled = YES;

        // Adding a UIToolbar with a clear button, programatically
        CGRect barRect = self.bounds;
        barRect.origin.y = 625;
        barRect.size.height = 44;
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:barRect];
        [toolbar sizeToFit];
        self.autoresizesSubviews = YES;
        toolbar.barStyle = UIBarStyleBlackTranslucent;
        // Buttons
        UIBarButtonItem *flex1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil
                                                                               action:nil];
        UIBarButtonItem *clearLines = [[UIBarButtonItem alloc] initWithTitle:@"Clear"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(clearLines)];
        UIBarButtonItem *flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil
                                                                               action:nil];
        clearLines.tintColor = [UIColor whiteColor];
        toolbar.items = @[flex1, clearLines, flex2];

        [self addSubview:toolbar];
    }

    return self;
}
#

#pragma mark - view Public methods
- (void)saveChanges
{
    BOOL success = [NSKeyedArchiver archiveRootObject:self.finishedLines toFile:DocsPath()];

    if (success) {
        NSLog(@"------OH YEAH------");
    } else {
        NSLog(@"------OH NO--------");
    }
}
#

#pragma mark - view Private methods
- (void)strokeLine:(Line *)line
{
    UIBezierPath *bp = [UIBezierPath bezierPath];
    bp.lineWidth = 10;
    bp.lineCapStyle = kCGLineCapRound;

    [bp moveToPoint:line.begin];
    [bp addLineToPoint:line.end];
    [bp stroke];
}

- (void)strokeArc:(Line *)line
{
    // Center
    CGPoint centerRect = {
        self.bounds.origin.x + self.bounds.size.width / 2,
        self.bounds.origin.y + self.bounds.size.height / 2
    };

    // Angles (radians)
    // Since drawing a circle will be using center of window as starting point
    // and line's begin/end points as 'end' for the line, for the angles (took serious time to figure out!)
    CGFloat startAngle = AngleBetweenTwoPoints(centerRect, line.begin) * M_PI / 180.0; // Relative to center of screen
    CGFloat endAngle = AngleBetweenTwoPoints(centerRect, line.end) * M_PI / 180.0; // Relative to center of screen

    // Radius
    // Get and set quadrant for angle
    line.lineQuadrant = QuadrantForAngle(AngleBetweenTwoPoints(centerRect, line.end));
    CGFloat radius = fabs((line.end.x - centerRect.x) + (line.end.y - centerRect.y));
    //MAX(fabs(line.begin.x - line.end.x), fabs(line.end.y - line.end.y)) / 2;
    //NSLog(@"Radius: %.2f", radius);

    // Path
    UIBezierPath *bp = [UIBezierPath bezierPathWithArcCenter:centerRect
                                                      radius:radius
                                                  startAngle:startAngle
                                                    endAngle:endAngle
                                                   clockwise:NO];
    bp.lineWidth = 15;
    bp.lineCapStyle = kCGLineCapRound;
    [bp stroke];
}

- (void)clearLines
{
    [self.finishedLines removeAllObjects];
    [self.finishedCircles removeAllObjects];

    [self setNeedsDisplay];
}

- (float)normalizeAngle:(float)angle from:(float)min to:(float)max {

    if (angle > max || angle < min) {
        //NSLog(@"normalizeAngle out of range.");
    }
    return (angle - min) / (max - min);
}

- (UIColor *)colorFromAngle:(Line *)line
{
    // Get angle for line (in degrees)
    CGFloat angleIn = AngleBetweenTwoPoints(line.begin, line.end);

    // Converting degrees to radian
    CGFloat angle = angleIn * M_PI / 180.0;

    // Normalize atan from [-pi, pi] to [0, 2pi]
    // Need this for the color logic below, otherwise you get limited color range
    if (angle < 0) {
        angle += 2 * M_PI;
    }

    // Begin color logic
    CGFloat r, g, b;

    // Each pi/3 interval gets different rules
    if (angle > 0 && angle <= 1 * M_PI / 6.0) { // 0 to 30deg
        r = [self normalizeAngle:angle
                            from:1 * M_PI / 6.0
                              to:3 * M_PI/ 6.0];
        g = 1;
        b = 0;
    }
    else if (angle > 1 * M_PI / 6.0 && angle <= 3 * M_PI / 6.0) { // 30 to 90deg
        r = 1;
        g = 1 - [self normalizeAngle:angle
                                from:1 * M_PI / 6.0
                                  to:3 * M_PI / 6.0];
        b = 0;
    }
    else if (angle > 3 * M_PI / 6.0 && angle <= 5 * M_PI / 6.0) { // 90 to 150deg
        r = 1;
        g = 0;
        b = [self normalizeAngle:angle
                            from:3 * M_PI / 6.0
                              to:5 * M_PI / 6.0];
    }
    else if (angle > 5 * M_PI / 6.0 && angle <= 7 * M_PI / 6.0) { // 150 to 210deg
        r = 1 - [self normalizeAngle:angle
                                from:5 * M_PI / 6.0
                                  to:7 * M_PI / 6.0];
        g = 0;
        b = 1;
    }
    else if (angle > 7 * M_PI / 6.0 && angle <= 9 * M_PI / 6.0) { // 210 to 270deg
        r = 0;
        g = [self normalizeAngle:angle
                            from:7 * M_PI / 6.0
                              to:9 * M_PI / 6.0];
        b = 1;
    }
    else if (angle > 9 * M_PI / 6.0 && angle <= 11 * M_PI / 6.0) { // 270 to 330deg
        r = 0;
        g = 1;
        b = 1 - [self normalizeAngle:angle
                                from:9 * M_PI / 6.0
                                  to:11 * M_PI / 6.0];
    }
    else { // 330 to 360deg
        r = [self normalizeAngle:angle
                            from:11 * M_PI / 6.0
                              to:13 * M_PI / 6.0];
        g = 1;
        b = 0;
    }

    //NSLog(@"radians:%f, R:%f, G:%f, B:%f", angle, r, g, b);

    return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}
#

- (void)drawRect:(CGRect)rect
{
    // Draw finished lines in black
    // [[UIColor blackColor] set]; // <-- switched to color based on angle
    for (Line *line in self.finishedLines) {
        UIColor *lineColor = [self colorFromAngle:line];
        [lineColor set];
        [self strokeLine:line];
    }

    for (Line *line in self.finishedCircles) {
        UIColor *lineColor = [self colorFromAngle:line];
        [lineColor set];
        [self strokeArc:line];
    }

    /*
    if (self.currentLine) {
        // If there is a line currently being drawn, do it in red
        [[UIColor redColor] set];
        [self strokeLine:self.currentLine];
    }
     */

    [[UIColor redColor] set];
    for (NSValue *key in self.linesInProgress) {
        if (self.lineType == straight) {
            [self strokeLine:self.linesInProgress[key]];
        }
        else if (self.lineType == arc) {
            [self strokeArc:self.linesInProgress[key]];
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // Let's put in a log statement to see the order of events
    //NSLog(@"%@", NSStringFromSelector(_cmd));

    // Enumerate through the set of touches and...
    // ...instantiate a Line object per touch (multitouch)
    // ...configure each line w/the location off the touch object
    // ...generate a key value based off of touch object's memory address
    // ...add the lines to the dictionary
    for (UITouch *t in touches) {
        CGPoint location = [t locationInView:self];

        Line *line = [[Line alloc] init];
        line.begin = location;
        line.end = location;

        // Get a key based on object memory location
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        self.linesInProgress[key] = line;
    }

    /*
    // Get location of the touch in view's coordinate system
    CGPoint location = [t locationInView:self];

    self.currentLine = [[Line alloc] init];
    self.currentLine.begin = location;
    self.currentLine.end = location;
     */

    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    /*
    UITouch *t = [touches anyObject];
    CGPoint location = [t locationInView:self];

    self.currentLine.end = location;
     */

    // Let's put a log statement to see the order of events
    //NSLog(@"%@", NSStringFromSelector(_cmd));

    // Define array for quadrant logic
    NSMutableArray *array = [[NSMutableArray alloc] init];

    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        Line *line = self.linesInProgress[key];
        line.end = [t locationInView:self];

        // Begin circle logic
        // If touch set == 2 fingers, get and set quadrant for each line
        // and add to an array for further evaluation
        if (touches.count == 2) {
            line.lineQuadrant = QuadrantForAngle(AngleBetweenTwoPoints(line.begin, line.end));
            [array addObject:line];
        }
    }

    // ... continued circle logic
    if (array.count) {
        self.lineType = arc;
    } else {
        self.lineType = straight;
    }

    array = nil;

    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    /*
    [self.finishedLines addObject:self.currentLine];

    self.currentLine = nil;
     */

    // Let's put a log statement to see the order of events
    //NSLog(@"%@", NSStringFromSelector(_cmd));

    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        Line *line = self.linesInProgress[key];

        if (self.lineType == arc) {
            [self.finishedCircles addObject:line];
        } else {
            [self.finishedLines addObject:line];
        }

        [self.linesInProgress removeObjectForKey:key];
    }

    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // Let's put a log statement to see the order of events
    //NSLog(@"%@", NSStringFromSelector(_cmd));

    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        [self.linesInProgress removeObjectForKey:key];
    }

    [self setNeedsDisplay];
}

// Playing with motion event (using it to clear lines)
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeMotion && motion == UIEventSubtypeMotionShake) {
        [self clearLines];
    }
}

@end
