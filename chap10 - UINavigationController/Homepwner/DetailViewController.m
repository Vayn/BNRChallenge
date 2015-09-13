//
//  DetailViewController.m
//  Homepwner
//
//  Created by Vicent Tsai on 15/8/18.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "DetailViewController.h"
#import "Item.h"
#import "DateViewController.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *serialNumberField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeDateBtn;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    // Clear first responder
    [self.view endEditing:YES];

    // Save changes to item
    Item *item = self.item;
    item.itemName = self.nameField.text;
    item.serialNumber = self.serialNumberField.text;
    item.valueInDollars = [self.valueField.text intValue];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    Item *item = self.item;

    self.nameField.text = item.itemName;
    self.serialNumberField.text = item.serialNumber;
    self.valueField.text = [NSString stringWithFormat:@"%d", item.valueInDollars];

    // You need an  NSDateFormatter that will ture a date into a simple date string
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }

    // Use filtered NSDate object to set dateLabel contents
    self.dateLabel.text = [dateFormatter stringFromDate:item.dateCreated];
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

// Silver Challenge
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.valueField resignFirstResponder];
}

- (IBAction)changeDate:(id)sender
{
    DateViewController *dateViewController = [[DateViewController alloc] init];
    dateViewController.item = self.item;

    [self.navigationController pushViewController:dateViewController animated:YES];
}

@end
