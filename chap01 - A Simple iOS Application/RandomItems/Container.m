//
//  Container.m
//  RandomItems
//
//  Created by Vicent Tsai on 15/8/5.
//  Copyright (c) 2015年 Big Nerd Ranch. All rights reserved.
//

#import "Container.h"

@implementation Container

- (instancetype)initWithContainerName:(NSString *)name subItems:(NSMutableArray *)sItems
{
    NSString *containerName = [NSString stringWithFormat:@"CONT %@", name];
    self = [super initWithItemName:containerName];

    if (self) {
        _subItems = sItems;
    }

    return self;
}

- (instancetype)initWithContainerName:(NSString *)name
{
    return [self initWithContainerName:name
                              subItems:[[NSMutableArray alloc] init]];
}

- (instancetype)init
{
    return [self initWithContainerName:@"Container"];
}

- (void)addItem:(Item *)item
{
    [_subItems addObject:item];
}

- (void)setValueInDollars:(int)v
{
    NSLog(@"Setting value on a Container object is not supported!");
}

- (int)valueInDollars
{
    int valueOfAllSubitems = 0;

    for (Item *item in _subItems) {
        valueOfAllSubitems += item.valueInDollars;
    }

    return valueOfAllSubitems;
}

- (NSString *)description
{
    NSMutableString *desc = [[NSMutableString alloc] initWithString:[super description]];
    [desc appendString:@";\nsubitems={\n"];
    for (Item *item in _subItems) {
        [desc appendString:@"    "];
        [desc appendString:[item description]];
        [desc appendString:@", \n"];
    }
    [desc appendString:@"}"];
    return [desc copy];
}

@end
