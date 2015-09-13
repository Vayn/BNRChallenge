//
//  BNRImageTransformer.m
//  HomePwner
//
//  Created by Vicent Tsai on 15/9/12.
//  Copyright © 2015年 Big Nerd Ranch. All rights reserved.
//

#import "BNRImageTransformer.h"

@implementation BNRImageTransformer

+ (Class)transformedValueClass
{
    return [NSData class];
}

- (id)transformedValue:(id)value
{
    if (!value) {
        return nil;
    }

    if ([value isKindOfClass:[NSData class]]) {
        return value;
    }

    return UIImagePNGRepresentation(value);
}

- (id)reverseTransformedValue:(id)value
{
    return [UIImage imageWithData:value];
}

@end
