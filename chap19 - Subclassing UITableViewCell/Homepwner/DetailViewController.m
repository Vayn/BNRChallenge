//
//  DetailViewController.m
//  Homepwner
//
//  Created by Vicent Tsai on 15/8/18.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "DetailViewController.h"
#import "Item.h"
#import "ImageStore.h"
#import "ItemStore.h"

@interface DetailViewController () <UINavigationControllerDelegate,
                                    UIImagePickerControllerDelegate,
                                    UITextFieldDelegate,
                                    UIPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *serialNumberField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraBtn;
@property (strong, nonatomic) UIPopoverController *imagePickerPopover;

@end

@implementation DetailViewController

- (instancetype)initForNewItem:(BOOL)isNew
{
    self = [super initWithNibName:nil bundle:nil];

    if (self) {
        if (isNew) {
            UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                      target:self
                                                                                      action:@selector(save:)];
            self.navigationItem.rightBarButtonItem = doneItem;

            UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                        target:self
                                                                                        action:@selector(cancel:)];
            self.navigationItem.leftBarButtonItem = cancelItem;
        }
    }

    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    @throw [NSException exceptionWithName:@"Wrong initializer"
                                   reason:@"Use initForNewItem"
                                 userInfo:nil];
}

- (void)prepareViewsForOrientation:(UIInterfaceOrientation)orientation
{
    // Is it an iPad? No preparation necessary
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return;
    }

    // Is it landscape?
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        self.imageView.hidden = YES;
        self.cameraBtn.enabled = NO;
    } else {
        self.imageView.hidden = NO;
        self.cameraBtn.enabled = YES;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    [self prepareViewsForOrientation:toInterfaceOrientation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    UIImageView *iv = [[UIImageView alloc] initWithImage:nil];

    // The contentMode of the image view in XIB was Aspect fit:
    iv.contentMode = UIViewContentModeScaleAspectFill;

    // Do not produce a translated constraint for this view
    iv.translatesAutoresizingMaskIntoConstraints = NO;

    // The image view was a subview of the view
    [self.view addSubview:iv];

    // The image view was pointed to by the imageView property
    self.imageView = iv;

    // Set the vertical priorities to be less than
    // those of the other subviews
    [self.imageView setContentHuggingPriority:200 forAxis:UILayoutConstraintAxisVertical];
    [self.imageView setContentCompressionResistancePriority:700 forAxis:UILayoutConstraintAxisVertical];

    NSDictionary *nameMap = @{@"imageView": self.imageView,
                              @"dateLabel": self.dateLabel,
                              @"toolbar": self.toolbar};

    // imageView is 0 pts from superview at left and right edges
    NSArray *horizontalConstrains = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView]-0-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:nameMap];

    // imageView is 8 pts from dateLabel at its top edge...
    // ... and 8 pts from toolbar at its bottom edge
    NSArray *verticalConstrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[dateLabel]-[imageView]-[toolbar]"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:nameMap];

    [self.view addConstraints:horizontalConstrains];
    [self.view addConstraints:verticalConstrains];
}

- (void)viewWillAppear:(BOOL)animated
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

    NSString *imageKey = self.item.itemKey;

    // Get the image for its image key from the image store
    UIImage *imageToDisplay = [[ImageStore sharedStore] imageForKey:imageKey];

    // Use that image to put on the screen in the image view
    self.imageView.image = imageToDisplay;

    UIInterfaceOrientation io = [[UIApplication sharedApplication] statusBarOrientation];
    [self prepareViewsForOrientation:io];
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

/*
- (void)viewDidLayoutSubviews
{
    for (UIView *subview in self.view.subviews) {
        if ([subview hasAmbiguousLayout]) {
            NSLog(@"AMBIGUOUS: %@", subview);
        }
    }
}
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setItem:(Item *)item
{
    _item = item;
    self.navigationItem.title = _item.itemName;
}

- (IBAction)takePicture:(id)sender {
    if ([self.imagePickerPopover isPopoverVisible]) {
        // If the popover is already up, get rid of it
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
        return;
    }

    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];

    // If the device has a camera, take a picture, otherwise,
    // just pick from photo library
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    imagePicker.delegate = self;

    /*
    // Place image picker on the screen
    [self presentViewController:imagePicker
                       animated:YES
                     completion:nil];
     */

    // Place image picker on the screen
    // Check for iPad device before instantiating the popover controller
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        // Create a new popover controller that wil display the image picker
        self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        self.imagePickerPopover.delegate = self;

        // Display the popover controller; sender
        // is the camera bar button item
        [self.imagePickerPopover presentPopoverFromBarButtonItem:sender
                                        permittedArrowDirections:UIPopoverArrowDirectionAny
                                                        animated:YES];
    } else {
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // Get picked image from info dictionary
    UIImage *image = info[UIImagePickerControllerOriginalImage];

    [self.item setThumbnailFromImage:image];

    // Store the image in the ImageStore for this key
    [[ImageStore sharedStore] setImage:image forKey:self.item.itemKey];

    // Put that image onto the screen in our image view
    self.imageView.image = image;

    /*
    // Take image picker off the screen -
    // you must call this dismiss method
    [self dismissViewControllerAnimated:YES completion:nil];
     */

    // Do I have a popover?
    if (self.imagePickerPopover) {
        // Dismiss it
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
    } else {
        // Dismiss the modal image picker
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    NSLog(@"User dismiss popover");
    self.imagePickerPopover = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    return YES;
}

- (IBAction)backgroundTapped:(id)sender {
    [self.view endEditing:YES];

    /*
    for (UIView *subview in self.view.subviews) {
        if ([subview hasAmbiguousLayout]) {
            [subview exerciseAmbiguityInLayout];
        }
    }
     */
}

- (void)save:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:self.dismissBlock];
}

- (void)cancel:(id)sender
{
    // If the user cancelled, then remove the Item from the store
    [[ItemStore sharedStore] removeItem:self.item];

    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:self.dismissBlock];
}

@end
