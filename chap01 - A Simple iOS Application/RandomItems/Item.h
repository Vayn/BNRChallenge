//
//  Item.h
//  RandomItems
//
//  Created by Vicent Tsai on 15/8/4.
//  Copyright (c) 2015年 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject
@property (nonatomic) NSString *itemName;
@property (nonatomic) NSString *serialNumber;
@property (nonatomic) int valueInDollars;
@property (nonatomic) NSDate *dateCreated;

+ (instancetype)randomItem;

// Designated intializer for Item
- (instancetype)initWithItemName:(NSString *)name valueInDollars:(int)value serialNumber:(NSString *)sNumber;
- (instancetype)initWithItemname:(NSString *)name serialNumber:(NSString *)sNumber;
- (instancetype)initWithItemName:(NSString *)name;

- (NSDate *)dateCreated;

@end
