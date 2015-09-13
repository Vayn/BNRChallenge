//
//  Item.h
//  RandomItems
//
//  Created by Vicent Tsai on 15/8/4.
//  Copyright (c) 2015年 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject

@property (nonatomic, copy) NSString *itemName;
@property (nonatomic, copy) NSString *serialNumber;
@property (nonatomic) int valueInDollars;
@property (nonatomic, readonly, strong) NSDate *dateCreated;

+ (instancetype)randomItem;

// Designated intializer for Item
- (instancetype)initWithItemName:(NSString *)name valueInDollars:(int)value serialNumber:(NSString *)sNumber;
- (instancetype)initWithItemName:(NSString *)name;

@end
