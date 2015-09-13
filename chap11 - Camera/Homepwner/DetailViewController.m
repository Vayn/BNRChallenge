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

@interface DetailViewController () <UINavigationControllerDelegate,
                                    UIImagePickerControllerDelegate,
                                    UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *serialNumberField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashBtn;
@property (weak, nonatomic) IBOutlet UIView *overlayView;

@property (strong, nonatomic) UIImagePickerController *imagePicker;

@end

@implementation DetailViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // Gold Challenge - notificaitons to hide overlayview when image is being previewed //
    // Register for camera pick controller notifications
    // NOTE: always store the observer so you can remove it from notificaiton center when done
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideOverlay:)
                                                 name:@"_UIImagePickerControllerUserDidCaptureItem"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideOverlay:)
                                                 name:@"_UIImagePickerControllerUserDidRejectItem"
                                               object:nil];
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

    if (!imageToDisplay) {
        imageToDisplay = [UIImage imageNamed:@"no_image.jpg"];
        self.trashBtn.enabled = NO;
    }

    // Use that image to put on the screen in the image view
    self.imageView.image = imageToDisplay;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)setItem:(Item *)item
{
    _item = item;
    self.navigationItem.title = _item.itemName;
}

- (IBAction)takePicture:(id)sender {
    self.imagePicker = [[UIImagePickerController alloc] init];

    // If the device has a camera, take a picture, otherwise,
    // just pick from photo library
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    // You can switch between camera image and video record now

    NSArray *availableTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    self.imagePicker.mediaTypes = availableTypes;

    // Gold Challenge
    [[NSBundle mainBundle] loadNibNamed:@"OverlayView" owner:self options:nil];
    self.imagePicker.cameraOverlayView = self.overlayView;

    // Bronze Challenge
    self.imagePicker.allowsEditing = YES;
    // Define delegate
    self.imagePicker.delegate = self;

    // Place image picker on the screen
    [self presentViewController:self.imagePicker
                       animated:YES
                     completion:nil];
}

// Silver Challenge
- (IBAction)removeImage:(id)sender {
    [[ImageStore sharedStore] deleteImageForKey:self.item.itemKey];

    self.imageView.image = [UIImage imageNamed:@"no_image.jpg"];

    self.trashBtn.enabled = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    return YES;
}

- (IBAction)backgroundTapped:(id)sender {
    [self.view endEditing:YES];
}

// Gold Challenge
// Notification action - hidding overlay via notification ceter observers,
// during preview mode
- (void)hideOverlay:(NSNotification *)note
{
    // Log the notification
    NSLog(@"%@", note.name);

    if ([note.name isEqualToString:@"_UIImagePickerControllerUserDidCaptureItem"]) {
        //self.overlayView.hidden = YES;
        self.imagePicker.cameraOverlayView = nil;
    } else {
        //self.overlayView.hidden = NO;
        self.imagePicker.cameraOverlayView = self.overlayView;
    }
}

#pragma mark - UIImagePickerController Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    /*
    // Get picked image from info dictionary
    UIImage *image = info[UIImagePickerControllerOriginalImage];
     */

    NSURL *mediaURL = info[UIImagePickerControllerMediaURL];

    if (mediaURL) {
        // Make sure this device supports videos in its photo album
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([mediaURL path])) {
            // Save the video to the photo album
            UISaveVideoAtPathToSavedPhotosAlbum([mediaURL path], nil, nil, nil);
            
            // Remove the video from temporary directory
            [[NSFileManager defaultManager] removeItemAtPath:[mediaURL path] error:nil];
        }
    } else {
        // Bronze Challenge
        UIImage *image = info[UIImagePickerControllerEditedImage];

        // Store the image in the ImageStore for this key
        [[ImageStore sharedStore] setImage:image forKey:self.item.itemKey];

        // Put that image onto the screen in our image view
        self.imageView.image = image;
        self.trashBtn.enabled = YES;
    }

    // Take image picker off the screen -
    // you must call this dismiss method
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
