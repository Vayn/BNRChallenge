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

@property (nonatomic, strong) IBOutlet UIView *headerView;

@end

@implementation ItemsTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    // Call the superclass's designated initializer
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {

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

    UIView *header = self.headerView;
    [self.tableView setTableHeaderView:header];
}

- (UIView *)headerView
{
    // If you have not loaded headerView yet
    if (!_headerView) {
        // Load HeaderView.xib
        [[NSBundle mainBundle] loadNibNamed:@"HeaderView"
                                      owner:self
                                    options:nil];
    }
    return _headerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[ItemStore sharedStore] allItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    // Create an instance of UITableViewCell, with default appearance
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:@"UITableViewCell"];
     */

    // Get a new or recycled cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"
                                                            forIndexPath:indexPath];

    // Set the text on the cell with the description of item
    // that is at the nth index of items, where n = row, this
    // cell will appear in on the tableview
    NSArray *items = [[ItemStore sharedStore] allItems];
    Item *item = items[indexPath.row];

    cell.textLabel.text = [item description];

    return cell;
}

- (IBAction)addNewItem:(id)sender
{
    // Create a new Item and add it to the store
    Item *newItem = [[ItemStore sharedStore] createItem];

    // Figure out where that item is in the array
    NSInteger lastRow = [[[ItemStore sharedStore] allItems] indexOfObject:newItem];

    // Make a new index path for the 0th section, last row
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastRow inSection:0];

    // Insert this new row into the table
    [self.tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationTop];
}

- (IBAction)toggleEditingMode:(id)sender
{
    // If you are currently in editing mode
    if (self.isEditing) {
        // Change text of button to inform user of state
        [sender setTitle:@"Edit" forState:UIControlStateNormal];

        // Turn off editing mode
        [self setEditing:NO animated:YES];
    } else {
        // Change text of button to inform user of state
        [sender setTitle:@"Done" forState:UIControlStateNormal];

        // Enter editing mode
        [self setEditing:YES animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                                            forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If the table view is asking to commit a delete command
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *items = [[ItemStore sharedStore] allItems];
        Item *item = items[indexPath.row];

        [[ItemStore sharedStore] removeItem:item];

        // Also remove that row from the table view with an animation
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
                                                  toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[ItemStore sharedStore] moveItemAtIndex:sourceIndexPath.row
                                     toIndex:destinationIndexPath.row];
}

// Bronze Challenge
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Remove";
}

// Silver Challenge
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isEditable = YES;
    NSUInteger count = [[[ItemStore sharedStore] allItems] count];

    if (indexPath.row == count - 1) {
        isEditable = NO;
    }

    return isEditable;
}

// Gold Challenge
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
                                                                         toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (proposedDestinationIndexPath.row == [[[ItemStore sharedStore] allItems] count] - 1) {
        return sourceIndexPath;
    } else {
        return proposedDestinationIndexPath;
    }
}

@end
