//
//  Line.h
//  TouchTracker
//
//  Created by Vicent Tsai on 15/8/20.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Line : NSObject <NSCoding>

@property (nonatomic) CGPoint begin;
@property (nonatomic) CGPoint end;
@property (nonatomic) float lineWidth;
@property (nonatomic, strong) UIColor *color;

@end
