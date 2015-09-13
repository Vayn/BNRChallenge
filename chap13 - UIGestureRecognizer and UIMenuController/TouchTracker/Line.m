//
//  Line.m
//  TouchTracker
//
//  Created by Vicent Tsai on 15/8/20.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "Line.h"

@implementation Line

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    if (self) {
        NSValue *begin = [aDecoder decodeObjectForKey:@"begin"];
        NSValue *end = [aDecoder decodeObjectForKey:@"end"];

        CGPoint point;

        [begin getValue:&point];
        self.begin = point;

        [end getValue:&point];
        self.end = point;
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSValue *beginValue = [NSValue valueWithCGPoint:self.begin];
    NSValue *endValue = [NSValue valueWithCGPoint:self.end];

    [aCoder encodeObject:beginValue forKey:@"begin"];
    [aCoder encodeObject:endValue forKey:@"end"];
}

@end
