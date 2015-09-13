//
//  BNRItem.m
//  HomePwner
//
//  Created by Vicent Tsai on 15/9/12.
//  Copyright © 2015年 Big Nerd Ranch. All rights reserved.
//

#import "BNRItem.h"

@implementation BNRItem

- (void)setThumbnailFromImage:(UIImage *)image
{
    CGSize originalImageSize = image.size;

    CGRect newRect = CGRectMake(0, 0, 40, 40);

    float ratio = MAX(newRect.size.width / originalImageSize.width,
                      newRect.size.height / originalImageSize.height);

    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);

    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect
                                                    cornerRadius:5.0];

    [path addClip];

    CGRect projectRect;
    projectRect.size.width = ratio * originalImageSize.width;
    projectRect.size.height = ratio * originalImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;

    [image drawInRect:projectRect];

    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    self.thumbnail = smallImage;

    UIGraphicsEndImageContext();
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];

    self.dateCreated = [NSDate date];

    // Create an NSUUID object - and get its string representation
    NSUUID *uuid = [[NSUUID alloc] init];
    NSString *key = [uuid UUIDString];
    self.itemKey = key;
}

@end
