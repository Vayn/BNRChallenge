//
//  ItemStore.m
//  Homepwner
//
//  Created by Vicent Tsai on 15/8/15.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "ItemStore.h"
#import "Item.h"

@interface ItemStore ()

@property (nonatomic) NSMutableArray *privateItems;

@end

@implementation ItemStore

+ (instancetype)sharedStore
{
    static ItemStore *sharedStore = nil;

    // Do I need to create a sharedStore?
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }

    return sharedStore;
}

// If a programmer calls [[ItemStore alloc] init], let him
// knows the error of his ways
- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[ItemStore sharedStore]"
                                 userInfo:nil];
}

// Here is the real (secret) initializer
- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        _privateItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray *)allItems
{
    return [self.privateItems copy];
}

- (Item *)createItem
{
    Item *item = [Item randomItem];

    [self.privateItems addObject:item];

    return item;
}

- (void)removeItem:(Item *)item
{
    [self.privateItems removeObjectIdenticalTo:item];
}

- (void)moveItemAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    if (fromIndex == toIndex) {
        return;
    }

    // Get pointer to object being moved so you can re-insert it
    Item *item = self.privateItems[fromIndex];

    // Remove item from array
    [self.privateItems removeObjectAtIndex:fromIndex];

    // Insert item in array at new location
    [self.privateItems insertObject:item atIndex:toIndex];
}

@end
