//
//  BNRItem.h
//  HomePwner
//
//  Created by Vicent Tsai on 15/9/12.
//  Copyright © 2015年 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface BNRItem : NSManagedObject

- (void)setThumbnailFromImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END

#import "BNRItem+CoreDataProperties.h"
