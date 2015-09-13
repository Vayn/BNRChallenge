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
#import "DetailViewController.h"

@interface ItemsTableViewController ()

@property (nonatomic, strong) IBOutlet UIView *headerView;

@end

@implementation ItemsTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    // Call the superclass's designated initializer
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Homepwner";

        // Create a new bar button item that will send
        // addNewItem: to ItemsTableViewController
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                             target:self
                                                                             action:@selector(addNewItem:)];

        // Set this bar button item as the right item in the navigationItem
        navItem.rightBarButtonItem = bbi;

        navItem.leftBarButtonItem = self.editButtonItem;
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

    /*
    UIView *header = self.headerView;
    [self.tableView setTableHeaderView:header];
     */
}

/*
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
 */

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.tableView reloadData];
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

    /*
    // Figure out where that item is in the array
    NSInteger lastRow = [[[ItemStore sharedStore] allItems] indexOfObject:newItem];

    // Make a new index path for the 0th section, last row
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastRow inSection:0];

    // Insert this new row into the table
    [self.tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationTop];
     */

    DetailViewController *dvc = [[DetailViewController alloc] initForNewItem:YES];
    dvc.item = newItem;

    dvc.dismissBlock = ^{
        [self.tableView reloadData];
    };

    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:dvc];
//    nvc.modalPresentationStyle = UIModalPresentationFormSheet;
    nvc.modalTransitionStyle = UIModalTransitionStylePartialCurl;

    [self presentViewController:nvc animated:YES completion:nil];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //DetailViewController *detailViewController = [[DetailViewController alloc] init];
    DetailViewController *detailViewController = [[DetailViewController alloc] initForNewItem:NO];

    NSArray *items = [[ItemStore sharedStore] allItems];
    Item *selectedItem = items[indexPath.row];

    // Give detail view controller a pointer to the item object in row
    detailViewController.item = selectedItem;

    // Push it onto the top of the navigation controller's stack
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
