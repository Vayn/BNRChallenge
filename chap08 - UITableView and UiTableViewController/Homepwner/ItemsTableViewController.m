//
//  ItemsTableViewController.m
//  Homepwner
//
//  Created by Vicent Tsai on 15/8/15.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "ItemsTableViewController.h"
#import "ItemStore.h"
#import "Item.h"

@interface ItemsTableViewController ()

@property (nonatomic, copy) NSArray *itemsOverFifty;
@property (nonatomic, copy) NSArray *itemsUnderFifty;

@end

@implementation ItemsTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    // Call the superclass's designated initializer
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        for (int i = 0; i < 5; i++) {
            [[ItemStore sharedStore] createItem];
        }

        // **BRONZE CHALLENGE** using 2 sections, one for items > $50 bucks / one for <=
        NSArray *allItems = [[ItemStore sharedStore] allItems];
        NSMutableArray *overFifty = [[NSMutableArray alloc] init];
        NSMutableArray *underFifty = [[NSMutableArray alloc] init];

        for (Item *item in allItems) {
            if (item.valueInDollars > 50) {
                [overFifty addObject:item];
            } else {
                [underFifty addObject:item];
            }
        }

        self.itemsOverFifty = overFifty;
        self.itemsUnderFifty = underFifty;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithStyle:UITableViewStylePlain];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Register UITableViewCell class with the table view
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];

    // Same as above but for the footer/header object
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"UITableViewHeaderFooterView"];

    // **GOLD CHALLENGE part** make rows size 60
    self.tableView.rowHeight = 60;

    // **SILVER CHALLENGE part** required by the delegate methods below that return footers/headers
    self.tableView.sectionFooterHeight = 44;
    self.tableView.sectionHeaderHeight = 60;

    // ** GOLD CHALLENGE part** add background image to TableView
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparency.jpg"]];
    [backgroundImageView setFrame:self.tableView.frame];
    self.tableView.backgroundView = backgroundImageView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.itemsOverFifty count];
    } else {
        return [self.itemsUnderFifty count];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"UITableViewHeaderFooterView"];
    //headerView.contentView.backgroundColor = [UIColor lightGrayColor];

    if (section == 0) {
        headerView.textLabel.text = @"Items > $50";
    } else {
        headerView.textLabel.text = @"Items <= $50";
    }

    return headerView;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        ((UITableViewHeaderFooterView *)view).backgroundView.backgroundColor = [UIColor clearColor];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{

    UITableViewHeaderFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"UITableViewHeaderFooterView"];
    footerView.textLabel.text = @"No more items!";

    return footerView;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        ((UITableViewHeaderFooterView *)view).backgroundView.backgroundColor = [UIColor clearColor];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get a new or recycled cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"
                                                            forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];

    // Set the text on the cell with the description of item
    // that is at the nth index of items, where n = row, this
    // cell will appear in on the tableview
    Item *item;

    if (indexPath.section == 0) {
        item = self.itemsOverFifty[indexPath.row];
    } else {
        item = self.itemsUnderFifty[indexPath.row];
    }

    cell.textLabel.text = [item description];

    // **GOLD CHALLENGE part ** make text for rows text size 20
    cell.textLabel.font = [cell.textLabel.font fontWithSize:20.0];

    return cell;
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item *item, *lastItem;

    if (indexPath.section == 0) {
        item = [self.itemsOverFifty objectAtIndex:indexPath.row];
        lastItem = [self.itemsOverFifty lastObject];
    } else {
        item = [self.itemsUnderFifty objectAtIndex:indexPath.row];
        lastItem = [self.itemsUnderFifty lastObject];
    }

    if (item == lastItem) {
        return 44.0;
    } else {
        return 60.0;
    }
}
 */

@end
