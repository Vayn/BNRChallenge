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
#import "ItemCell.h"
#import "ImageStore.h"
#import "ImageViewController.h"

@interface ItemsTableViewController () <UIPopoverControllerDelegate>

/*
@property (nonatomic, strong) IBOutlet UIView *headerView;
 */
@property (nonatomic, strong) UIPopoverController *imagePopover;

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

    /*
    // Register UITableViewCell class with the table view
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
     */

    /*
    UIView *header = self.headerView;
    [self.tableView setTableHeaderView:header];
     */

    // Load the NIB file
    UINib *nib = [UINib nibWithNibName:@"ItemCell" bundle:nil];

    // Register this NIB, which contains the cell
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ItemCell"];
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

    /*
    // Get a new or recycled cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"
                                                            forIndexPath:indexPath];
     */

    // Get a new or recycled cell
    ItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemCell" forIndexPath:indexPath];

    // Set the text on the cell with the description of item
    // that is at the nth index of items, where n = row, this
    // cell will appear in on the tableview
    NSArray *items = [[ItemStore sharedStore] allItems];
    Item *item = items[indexPath.row];

    /*
    cell.textLabel.text = [item description];
     */

    // Configure the cell with the Item
    cell.nameLabel.text = item.itemName;
    cell.serialNumberLabel.text = item.serialNumber;

    if (item.valueInDollars > 50) {
        cell.valueLabel.textColor = [UIColor greenColor];
    } else {
        cell.valueLabel.textColor = [UIColor redColor];
    }
    cell.valueLabel.text = [NSString stringWithFormat:@"$%d", item.valueInDollars];

    cell.thumbnailView.image = item.thumbnail;

    __weak ItemCell *weakCell = cell;

    cell.actionBlock = ^{
        NSLog(@"Going to show image for %@", item);

        ItemCell *strongCell = weakCell;

        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            NSString *itemKey = item.itemKey;

            // If there is no image, we don't need to display anything
            UIImage *img = [[ImageStore sharedStore] imageForKey:itemKey];
            if (!img) {
                return;
            }

            // Make a rectangle for the frame of the thumbnail relative to
            // our table view
            // Note: there will be a warning on this line that we'll soon discuss
            CGRect rect = [self.view convertRect:strongCell.thumbnailView.bounds fromView:strongCell.thumbnailView];

            // Create a new ImageViewController and set its image
            ImageViewController *ivc = [[ImageViewController alloc] init];
            ivc.image = img;

            // Present a 600x600 popover from the rect
            self.imagePopover = [[UIPopoverController alloc] initWithContentViewController:ivc];
            self.imagePopover.delegate = self;
            self.imagePopover.popoverContentSize = CGSizeMake(600, 600);
            [self.imagePopover presentPopoverFromRect:rect
                                               inView:self.view
                             permittedArrowDirections:UIPopoverArrowDirectionAny
                                             animated:YES];
        }
    };

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
    nvc.modalPresentationStyle = UIModalPresentationFormSheet;
//    nvc.modalTransitionStyle = UIModalTransitionStylePartialCurl;
//    nvc.modalPresentationStyle = UIModalPresentationCurrentContext;
//    self.definesPresentationContext = YES;

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

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.imagePopover = nil;
}

@end
