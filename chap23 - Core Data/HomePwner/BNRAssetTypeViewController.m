//
//  BNRAssetTypeViewController.m
//  HomePwner
//
//  Created by Vicent Tsai on 15/9/13.
//  Copyright © 2015年 Big Nerd Ranch. All rights reserved.
//

#import "BNRAssetTypeViewController.h"
#import "BNRItemStore.h"
#import "BNRItem.h"
#import "BNRNewAssetTypeController.h"
#import "BNRItemCell.h"

@interface BNRAssetTypeViewController ()

@property (nonatomic, strong) UITableViewCell *checkedCell;

@end

@implementation BNRAssetTypeViewController

- (instancetype)init
{
    return [self initWithStyle:UITableViewStylePlain];
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self =  [super initWithStyle:UITableViewStylePlain];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                             target:self
                                                                             action:@selector(addNewAsset)];
        navItem.rightBarButtonItem = bbi;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];

    UINib *nib = [UINib nibWithNibName:@"BNRItemCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"BNRItemCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    NSString *typeName;

    if (!self.checkedCell.textLabel.text) {
        typeName = @"no type";
    } else {
        typeName = self.checkedCell.textLabel.text;
    }

    switch (section) {
        case 0:
            sectionName = @"Asset Types";
            break;
        case 1:
            sectionName = [NSString stringWithFormat:@"All items in %@", typeName];
            break;

        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger sum = 0;

    BNRItemStore *itemStore = [BNRItemStore sharedStore];
    NSPredicate *p = [NSPredicate predicateWithFormat:@"AssetType == %@", self.item.assetType];

    switch (section) {
        case 0:
            sum = [[itemStore allAssetTypes] count];
            break;
        case 1:
            sum = [[[itemStore allItems] filteredArrayUsingPredicate:p] count];
            break;

        default:
            break;
    }
    return sum;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BNRItemStore *itemStore = [BNRItemStore sharedStore];

    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];

        NSArray *allAssets = [itemStore allAssetTypes];
        NSManagedObject *assetType = allAssets[indexPath.row];

        // Use key-value coding to get the asset type's label
        NSString *assetLabel = [assetType valueForKey:@"label"];
        cell.textLabel.text = assetLabel;

        // Checkmark the one that is currently selected
        if (assetType == self.item.assetType) {
            self.checkedCell = cell;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }

        return cell;
    } else {
        BNRItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BNRItemCell" forIndexPath:indexPath];

        NSPredicate *p = [NSPredicate predicateWithFormat:@"AssetType == %@", self.item.assetType];
        NSArray *items = [[itemStore allItems] filteredArrayUsingPredicate:p];

        BNRItem *item = items[indexPath.row];
        cell.nameLabel.text = item.itemName;
        cell.serialNumberLabel.text = item.serialNumber;
        cell.valueLabel.text = [NSString stringWithFormat:@"$%d", item.valueInDollars];
        cell.thumbnailView.image = item.thumbnail;

        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if (indexPath.section == 0) {
        if (cell != self.checkedCell) {
            self.checkedCell.accessoryType = UITableViewCellAccessoryNone;
        }
        self.checkedCell = cell;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;

        NSArray *allAssets = [[BNRItemStore sharedStore] allAssetTypes];
        NSManagedObject *assetType = allAssets[indexPath.row];
        self.item.assetType = assetType;

        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            self.dismissBlock();
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)addNewAsset
{
    BNRNewAssetTypeController *newAssetTypeController = [[BNRNewAssetTypeController alloc] init];

    newAssetTypeController.popBack = ^{
        [self.tableView reloadData];
    };

    [self.navigationController pushViewController:newAssetTypeController animated:YES];
}

@end
