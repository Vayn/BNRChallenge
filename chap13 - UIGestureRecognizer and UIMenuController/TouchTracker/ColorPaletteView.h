//
//  ColorPaletteView.h
//  TouchTracker
//
//  Created by Vicent Tsai on 15/8/23.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorPaletteView : UIView

@property (nonatomic, strong) void(^completion)(UIColor *);

@end
