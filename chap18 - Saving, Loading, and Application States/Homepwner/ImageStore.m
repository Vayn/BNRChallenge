//
//  ImageStore.m
//  Homepwner
//
//  Created by Vicent Tsai on 15/8/19.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "ImageStore.h"
#import <UIKit/UIKit.h>

@interface ImageStore ()

@property (nonatomic, strong) NSMutableDictionary *dict;

- (NSString *)imagePathForKey:(NSString *)key;

@end

@implementation ImageStore

+ (instancetype)sharedStore
{
    static ImageStore *sharedStore = nil;

    /* // Single-threaded safe
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
     */

    // Thread-safe
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPrivate];
    });

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(clearCache:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];

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
    self.dict[key] = image;

    // Create full path for image
    NSString *imagePath = [self imagePathForKey:key];

    /* Bronze */
    // Turn image into PNG data
    NSData *data = UIImagePNGRepresentation(image);

    // Write it to full path
    [data writeToFile:imagePath atomically:YES];
}

- (UIImage *)imageForKey:(NSString *)key
{
    // If possible, get it from the dictionary
    UIImage *result = self.dict[key];

    if (!result) {
        NSString *imagePath = [self imagePathForKey:key];

        // Create UIImage object from file
        result = [UIImage imageWithContentsOfFile:imagePath];

        // If we found an image on the filesystem, place it into the cache
        if (result) {
            self.dict[key] = result;
        } else {
            NSLog(@"Error: unable to find %@", [self imagePathForKey:key]);
        }
    }
    
    return result;
}

- (void)deleteImageForKey:(NSString *)key
{
    if (!key) {
        return;
    }

    [self.dict removeObjectForKey:key];

    NSString *imagePath = [self imagePathForKey:key];
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
}

- (NSString *)imagePathForKey:(NSString *)key
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];

    return [documentDirectory stringByAppendingPathComponent:key];
}

- (void)clearCache:(NSNotificationCenter *)note
{
    NSLog(@"Flusing %d images out of the cache", [self.dict count]);
    [self.dict removeAllObjects];
}

@end
