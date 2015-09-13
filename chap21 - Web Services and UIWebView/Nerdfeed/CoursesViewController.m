//
//  CoursesViewController.m
//  Nerdfeed
//
//  Created by Vicent Tsai on 15/9/11.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "CoursesViewController.h"
#import "WebViewController.h"
#import "CourseCell.h"

@interface CoursesViewController () <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, copy) NSArray *courses;

@end

@implementation CoursesViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.navigationItem.title = @"BNR Courses";

        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
        [self fetchFeed];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UINib *nib = [UINib nibWithNibName:@"CourseCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"CourseCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*
     return [self.courses count];
     */
    NSInteger sum = 0;
    for (NSDictionary *course in self.courses) {
        if ([course objectForKey:@"upcoming"]) {
            NSArray *upcoming = [course objectForKey:@"upcoming"];
            for (int i = 0; i < [upcoming count]; i++) {
                sum++; // count every upcoming course date
            }
        } else {
            sum++; // and count every course without upcoming dates
        }
    }
    return sum;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    CourseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CourseCell"
                                                       forIndexPath:indexPath];
    NSDictionary *course = self.courses[indexPath.row];
    NSDictionary *details = [course[@"upcoming"] objectAtIndex:0];

    cell.titleLabel.text = course[@"title"];

    if (details) {
        cell.dateLabel.text = details[@"start_date"];
        cell.instructorLabel.text = details[@"instructors"];
    }else{
        cell.dateLabel.text = @"TBA";
        cell.instructorLabel.text = @"TBA";
    }
    return cell;
     */
    CourseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CourseCell"
                                                       forIndexPath:indexPath];
    NSInteger i = -1;
    for (NSDictionary *course in self.courses) { // for every course in the array of courses received
        if ([course objectForKey:@"upcoming"]) { // if course has upcoming dates
            NSArray *upcoming = [course objectForKey:@"upcoming"];
            for (NSDictionary *upcomingDate in upcoming) { // for every upcoming date
                i++; // count the date as a row
                if (indexPath.row == i) { // if this date's row is current indexPath
                    cell.titleLabel.text = course[@"title"];
                    cell.instructorLabel.text = upcomingDate[@"instructors"];
                    cell.dateLabel.text = upcomingDate[@"start_date"];
                    break;
                }
            }
        } else { // course has no upcoming dates
            i++; // count the course as a row
            if (indexPath.row == i) { // if this course's row is the current indexPath
                cell.titleLabel.text = course[@"title"];
                cell.instructorLabel.text = @"None";
                cell.dateLabel.text = @"None";
                break;
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    NSDictionary *course = self.courses[indexPath.row];
    NSURL *URL = [NSURL URLWithString:course[@"url"]];

    self.webViewController.title = course[@"title"];
    self.webViewController.URL = URL;
    [self.navigationController pushViewController:self.webViewController animated:YES];
     */
    NSDictionary *course = [[NSDictionary alloc] init];
    NSInteger i = -1;
    for (NSDictionary *aCourse in self.courses) { // for every course in received array of courses
        if ([aCourse objectForKey:@"upcoming"]) { // if course has upcoming dates
            NSArray *upcoming = [aCourse objectForKey:@"upcoming"];
            for (int j = 0; j < [upcoming count]; j++) {
                i++; // count every upcoming date
                if (indexPath.row == i) { // if date's row is selected row
                    course = aCourse; // use this course
                    break;
                }
            }
        } else { // if course has no upcoming dates
            i++; // count the course
            if (indexPath.row == i) { // if course's row is selected row
                course = aCourse; // use this course
                break;
            }
        }
    }
    NSURL *URL = [NSURL URLWithString:course[@"url"]];

    self.webViewController.title = course[@"title"];
    self.webViewController.URL = URL;
    [self.navigationController pushViewController:self.webViewController
                                         animated:YES];
}

- (void)fetchFeed
{
    NSString *requestString = @"https://bookapi.bignerdranch.com/private/courses.json";
    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:req
                                                     completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error) {
                                          NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                                                                     options:0
                                                                                                       error:nil];
                                          self.courses = jsonObject[@"courses"];

                                          NSLog(@"%@", self.courses);

                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [self.tableView reloadData];
                                          });
                                      }];
    [dataTask resume];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    NSURLCredential *cred = [NSURLCredential credentialWithUser:@"BigNerdRanch"
                                                       password:@"AchieveNerdvana"
                                                    persistence:NSURLCredentialPersistenceForSession];
    completionHandler(NSURLSessionAuthChallengeUseCredential, cred);
}

@end
