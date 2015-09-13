//
//  ImageStore.m
//  Homepwner
//
//  Created by Vicent Tsai on 15/8/19.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "ImageStore.h"

@interface ImageStore ()

@property (nonatomic, strong) NSMutableDictionary *dict;

@end

@implementation ImageStore

+ (instancetype)sharedStore
{
    static ImageStore *sharedStore = nil;

    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }

    return sharedStore;
}

// No one should call init
- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[ImageStore sharedStore]"
                                 userInfo:nil];
    return nil;
}

// Secret Designated initializer
- (instancetype)initPrivate
{
    self = [super init];

    if (self) {
        _dict = [[NSMutableDictionary alloc] init];
    }

    return self;
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key
{
    //[self.dict setObject:image forKey:key];
    self.dict[key] = image;
}

- (UIImage *)imageForKey:(NSString *)key
{
    //return [self.dict objectForKey:key];
    return self.dict[key];
}

- (void)deleteImageForKey:(NSString *)key
{
    if (!key) {
        return;
    }

    [self.dict removeObjectForKey:key];
}

@end
