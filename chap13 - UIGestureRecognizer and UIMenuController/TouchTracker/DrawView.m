//
//  DrawView.m
//  TouchTracker
//
//  Created by Vicent Tsai on 15/8/20.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "DrawView.h"
#import "Line.h"
#import "ColorPaletteView.h"

#pragma mark - C helper functions
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

    // Output angle (in degrees) and quadrant
    if (radian >= 0 && radian < M_PI/2) {
        NSLog(@"%.2f degrees: 1st Quadrant", angle);
    }
    else if (radian >= M_PI/2 && radian < M_PI) {
        NSLog(@" %.2f degrees : 2nd Quadrant", angle);
    }
    else if (radian >= -M_PI && radian < -M_PI/2) {
        NSLog(@" %.2f degrees : 3rd Quadrant", angle);
    }
    else if (radian >= -M_PI/2 && radian < 0) {
        NSLog(@" %.2f degrees : 4th Quadrant", angle);
    }

    return angle;
}

#pragma mark - Class extension
@interface DrawView () <UIGestureRecognizerDelegate>

//@property (nonatomic, strong) Line *currentLine;
@property (nonatomic, strong) NSMutableDictionary *linesInProgress;
@property (nonatomic, strong) NSMutableArray *finishedLines;
@property (nonatomic, weak) Line *selectedLine;

@property (nonatomic, strong) UIPanGestureRecognizer *moveRecognizer;
@property (nonatomic, strong) NSMutableArray *panSpeed;

@property (nonatomic, strong) UIColor *currentColor;

@end

#pragma mark - View implementation
@implementation DrawView

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        self.linesInProgress = [[NSMutableDictionary alloc] init];
        self.finishedLines = [[NSMutableArray alloc] init];
        self.panSpeed = [[NSMutableArray alloc] init];

        // Load saved lines if they exist
        NSMutableArray *plist = [NSKeyedUnarchiver unarchiveObjectWithFile:DocsPath()];
        //NSLog(@"Type of plist: %@", [plist class]);
        
        if (plist) {
            self.finishedLines = plist;
            NSLog(@"Saved lines found, loading...\n\n %@", plist);
        } else {
            NSLog(@"No saved lines found...");
        }

        self.backgroundColor = [UIColor grayColor];
        self.multipleTouchEnabled = YES;

        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(doubleTap:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        doubleTapRecognizer.delaysTouchesBegan = YES;
        [self addGestureRecognizer:doubleTapRecognizer];

        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(tap:)];
        tapRecognizer.delaysTouchesBegan = YES;
        [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
        [self addGestureRecognizer:tapRecognizer];

        UILongPressGestureRecognizer *pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                      action:@selector(longPress:)];
        [self addGestureRecognizer:pressRecognizer];

        self.moveRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                      action:@selector(moveLine:)];
        self.moveRecognizer.delegate = self;
        self.moveRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:self.moveRecognizer];

        UISwipeGestureRecognizer *threeFingerSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(showColorPalette:)];
        threeFingerSwipe.direction = UISwipeGestureRecognizerDirectionUp;
        threeFingerSwipe.numberOfTouchesRequired = 3;
        threeFingerSwipe.delaysTouchesBegan = YES; // Prevent premature drawing
        [self addGestureRecognizer:threeFingerSwipe];
    }

    return self;
}

#pragma mark - Public methods
- (void)saveChanges
{
    BOOL success = [NSKeyedArchiver archiveRootObject:self.finishedLines toFile:DocsPath()];

    if (success) {
        NSLog(@"------OH YEAH------");
    } else {
        NSLog(@"------OH NO--------");
    }
}

#pragma mark - Gesture recognizers
- (void)doubleTap:(UIGestureRecognizer *)gr
{
    NSLog(@"Recognized Double Tap");

    [self.linesInProgress removeAllObjects];
    [self.finishedLines removeAllObjects];
    [self setNeedsDisplay];
}

- (void)tap:(UIGestureRecognizer *)gr
{
    NSLog(@"Recognized tap");

    CGPoint point = [gr locationInView:self];
    self.selectedLine = [self lineAtPoint:point];

    if (self.selectedLine) {
        // Make ourselves the target of menu item action messages
        [self becomeFirstResponder];

        // Grab the menu controller
        UIMenuController *menu = [UIMenuController sharedMenuController];

        // Create a new "Delete" UIMenuItem
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"Delete"
                                                            action:@selector(deleteLine:)];
        menu.menuItems = @[deleteItem];

        // Tell the menu where it should come from and show it
        [menu setTargetRect:CGRectMake(point.x, point.y, 2, 2) inView:self];
        [menu setMenuVisible:YES animated:YES];
    } else {
        // Hide the menu if no line is selected
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
    }

    [self setNeedsDisplay];
}

- (void)longPress:(UIGestureRecognizer *)gr
{
    if (gr.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gr locationInView:self];
        self.selectedLine = [self lineAtPoint:point];

        /*
        if (self.selectedLine) {
            [self.linesInProgress removeAllObjects];
        }*/
    } else if (gr.state == UIGestureRecognizerStateEnded) {
        self.selectedLine = nil;
    }

    [self setNeedsDisplay];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == self.moveRecognizer) {
        return YES;
    }

    return NO;
}

- (void)moveLine:(UIPanGestureRecognizer *)gr
{
    // Calculate the average speed of pan gesture
    CGPoint velocity = [gr velocityInView:self];
    float speed = hypotf(velocity.x, velocity.y);
    NSLog(@"Speed: %.2f", speed);
    [self.panSpeed addObject:[NSNumber numberWithFloat:speed]];

    // If we have not selected a line, wo do not do anything here
    if (!self.selectedLine) {
        return;
    }

    // When the pan recognizer changes its position...
    if (gr.state == UIGestureRecognizerStateChanged
                    // If you tap on a line and then start drawing a new one while the menu is visible,
                    // you will drag the selected line and draw a new line at the same time.
                    //
                    // The clause below fix the bug.
                    && ![[UIMenuController sharedMenuController] isMenuVisible]) {
        // How far has the pan moved?
        CGPoint translation = [gr translationInView:self];

        // Add the translation to the current beginning and end points of the line
        CGPoint begin = self.selectedLine.begin;
        CGPoint end = self.selectedLine.end;
        begin.x += translation.x;
        begin.y += translation.y;
        end.x += translation.x;
        end.y += translation.y;

        // Set the new beginning and end points of the line
        self.selectedLine.begin = begin;
        self.selectedLine.end = end;

        // Redraw the screen
        [self setNeedsDisplay];

        [gr setTranslation:CGPointZero inView:self];
    }
}

- (void)showColorPalette:(UISwipeGestureRecognizer *)gr
{
    NSLog(@"Recognized Swipe");

    // If the count of subview is not zero, it means there is alreay a color palette in DrawView,
    // so we don't need to add a new one to it. Otherwise, we add a new color palette to DrawView.
    if (self.subviews.count == 0) {
        ColorPaletteView *colorPaletteView = [[ColorPaletteView alloc] initWithFrame:self.frame];
        __weak DrawView *blockSelf = self;
        colorPaletteView.completion = ^(UIColor *chosenColor)
        {
            DrawView *innerSelf = blockSelf;
            if (chosenColor) {
                innerSelf.currentColor = chosenColor;
            }
        };

        [self addSubview:colorPaletteView];
    }
}

#pragma mark - Private methods
- (void)strokeLine:(Line *)line
{
    UIBezierPath *bp = [UIBezierPath bezierPath];
    bp.lineWidth = line.lineWidth;
    bp.lineCapStyle = kCGLineCapRound;

    [bp moveToPoint:line.begin];
    [bp addLineToPoint:line.end];
    [bp stroke];
}

- (void)deleteLine:(id)sender
{
    // Remove the selected line from the list of _finishedLines
    [self.finishedLines removeObject:self.selectedLine];

    // Redraw everything
    [self setNeedsDisplay];
}

- (Line *)lineAtPoint:(CGPoint)p
{
    // Find a line close to p
    for (Line *line in self.finishedLines) {
        CGPoint begin = line.begin;
        CGPoint end = line.end;

        // Check a few points on the line
        for (float t = 0.0; t <= 1.0; t += 0.05) {
            float x = begin.x + t * (end.x - begin.x);
            float y = begin.y + t * (end.y - begin.y);

            // If the tapped point is within 20 points, let's return this line
            if (hypotf(x - p.x, y - p.y) < 20.0) {
                return line;
            }
        }
    }

    // If nothing is close enough to the tapped point, then we did not select a line
    return nil;
}

- (float)normalizeAngle:(float)angle from:(float)min to:(float)max {

    if (angle > max || angle < min) {
        NSLog(@"normalizeAngle out of range.");
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
    else if (angle > 7 * M_PI / 6.0 && angle <= 9 * M_PI / 6.0) { //210 to 270deg
        r = 0;
        g = [self normalizeAngle:angle
                            from:7 * M_PI / 6.0
                              to:9 * M_PI / 6.0];
        b = 1;
    }
    else if (angle > 9 * M_PI / 6.0 && angle <= 11 * M_PI / 6.0) { //270 to 330deg
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

    NSLog(@"radians:%f, R:%f, G:%f, B:%f", angle, r, g, b);

    return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}

#pragma mark - UIResponder methods
- (void)drawRect:(CGRect)rect
{
    // Draw finished lines in black
    // [[UIColor blackColor] set]; // <-- switched to color based on angle
    for (Line *line in self.finishedLines) {
        if (line.color) {
            [line.color set];
        } else {
            UIColor *lineColor = [self colorFromAngle:line];
            [lineColor set];
        }

        [self strokeLine:line];
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
        [self strokeLine:self.linesInProgress[key]];
    }

    if (self.selectedLine) {
        [[UIColor whiteColor] set];
        [self strokeLine:self.selectedLine];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // Let's put in a log statement to see the order of events
    NSLog(@"%@", NSStringFromSelector(_cmd));

    for (UITouch *t in touches) {
        CGPoint location = [t locationInView:self];

        Line *line = [[Line alloc] init];
        line.begin = location;
        line.end = location;
        line.lineWidth = 3.0;

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
    /* // For single touch
    UITouch *t = [touches anyObject];
    CGPoint location = [t locationInView:self];

    self.currentLine.end = location;
     */

    // Let's put a log statement to see the order of events
    NSLog(@"%@", NSStringFromSelector(_cmd));

    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        Line *line = self.linesInProgress[key];

        line.end = [t locationInView:self];
    }

    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    /* // For single touch
    [self.finishedLines addObject:self.currentLine];

    self.currentLine = nil;
     */

    // Let's put a log statement to see the order of events
    NSLog(@"%@", NSStringFromSelector(_cmd));

    float averageSpeed = 0.0;
    for (NSNumber *num in self.panSpeed) {
        float speed = [num floatValue];
        averageSpeed += speed;
    }
    averageSpeed /= [self.panSpeed count];
    [self.panSpeed removeAllObjects];

    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        Line *line = self.linesInProgress[key];
        line.lineWidth = averageSpeed / 170;
        line.color = self.currentColor;

        [self.finishedLines addObject:line];
        [self.linesInProgress removeObjectForKey:key];
    }

    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // Let's put a log statement to see the order of events
    NSLog(@"%@", NSStringFromSelector(_cmd));

    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        [self.linesInProgress removeObjectForKey:key];
    }

    [self setNeedsDisplay];
}

@end
