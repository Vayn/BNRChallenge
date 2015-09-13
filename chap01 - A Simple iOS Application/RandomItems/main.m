//
//  main.m
//  RandomItems
//
//  Created by Vicent Tsai on 15/8/3.
//  Copyright (c) 2015年 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"
#import "Container.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Container *container = [[Container alloc] initWithContainerName:@"AST"];

        for (int i = 0; i < 10; i++) {
            Item *item = [Item randomItem];
            [container addItem:item];
        }

        //id eleventhItem = items[10];

        NSLog(@"%@", container);

        // Destroy the mutable array object
        container = nil;
    }
    return 0;
}
