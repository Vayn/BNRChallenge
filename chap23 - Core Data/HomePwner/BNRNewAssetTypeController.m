//
//  BNRNewAssetTypeController.m
//  HomePwner
//
//  Created by Vicent Tsai on 15/9/13.
//  Copyright © 2015年 Big Nerd Ranch. All rights reserved.
//

#import "BNRNewAssetTypeController.h"
#import "BNRItem.h"
#import "BNRItemStore.h"

@interface BNRNewAssetTypeController ()

@property (weak, nonatomic) IBOutlet UILabel *assetTypeLabel;
@property (weak, nonatomic) IBOutlet UITextField *assetTypeField;

@end

@implementation BNRNewAssetTypeController

- (instancetype)init
{
    self = [super init];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                             target:self
                                                                             action:@selector(addNewAssetType)];
        navItem.rightBarButtonItem = bbi;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addNewAssetType
{
    NSString *label = self.assetTypeField.text;
    BNRItemStore *itemStore = [BNRItemStore sharedStore];

    NSManagedObject *type = [NSEntityDescription insertNewObjectForEntityForName:@"BNRAssetType"
                                                          inManagedObjectContext:itemStore.context];

    [type setValue:label forKey:@"label"];
    [itemStore addAssetType:type];
    self.popBack();

    [self.navigationController popViewControllerAnimated:YES];
}

@end