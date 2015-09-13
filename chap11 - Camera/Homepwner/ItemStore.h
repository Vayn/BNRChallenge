//
//  ItemStore.h
//  Homepwner
//
//  Created by Vicent Tsai on 15/8/15.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Item;

@interface ItemStore : NSObject

@property (nonatomic, readonly) NSArray *allItems;

// Notice that this is a class method and prefixed with a + instead of a -
+ (instancetype)sharedStore;

- (Item *)createItem;
- (void)removeItem:(Item *)item;
- (void)moveItemAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end
