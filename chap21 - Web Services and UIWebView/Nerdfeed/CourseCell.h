//
//  CourseCell.h
//  Nerdfeed
//
//  Created by Vicent Tsai on 15/9/12.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourseCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *instructorLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
