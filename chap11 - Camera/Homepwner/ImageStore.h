//
//  ImageStore.h
//  Homepwner
//
//  Created by Vicent Tsai on 15/8/19.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;

@interface ImageStore : NSObject

+ (instancetype)sharedStore;

- (void)setImage:(UIImage *)image forKey:(NSString *)key;
- (UIImage *)imageForKey:(NSString *)key;
- (void)deleteImageForKey:(NSString *)key;

@end
