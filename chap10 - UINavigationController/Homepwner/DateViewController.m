//
//  DateViewController.m
//  Homepwner
//
//  Created by Vicent Tsai on 15/8/18.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "DateViewController.h"
#import "Item.h"

@interface DateViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@end

@implementation DateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Forcing datepicker date to always be future 60 sec
    self.datePicker.minimumDate = [NSDate dateWithTimeIntervalSinceNow:60];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    self.item.dateCreated = self.datePicker.date;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setItem:(Item *)item
{
    _item = item;
    self.navigationItem.title = _item.itemName;
}

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
