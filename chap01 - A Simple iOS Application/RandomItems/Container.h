//
//  Container.h
//  RandomItems
//
//  Created by Vicent Tsai on 15/8/5.
//  Copyright (c) 2015年 Big Nerd Ranch. All rights reserved.
//

#import "Item.h"

@interface Container : Item
@property NSMutableArray *subItems;

// Designated intializer
- (instancetype)initWithContainerName:(NSString *)name subItems:(NSArray *)sItems;
- (instancetype)initWithContainerName:(NSString *)name;

- (void)addItem:(Item *)item;

@end
