//
//  QuizViewController.m
//  Quiz
//
//  Created by Vicent Tsai on 15/8/2.
//  Copyright (c) 2015年 Big Nerd Ranch. All rights reserved.
//

#import "QuizViewController.h"

@interface QuizViewController ()

@property (nonatomic) int currentQuestionIndex;

@property (nonatomic, copy) NSArray *questions;
@property (nonatomic, copy) NSArray *answers;

@property (nonatomic, weak) IBOutlet UILabel *questionLabel;
@property (nonatomic, weak) IBOutlet UILabel *answerLabel;

@end

@implementation QuizViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    // Call the init method implemented by the superclass
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        // Create two arrays filled with questions and answers
        // and make the pointers point to them
        self.questions = @[@"From what is cognac made?",
                           @"What is 7+7?",
                           @"What is the capital of Vermont?"];
        self.answers = @[@"Grapes",
                         @"14",
                         @"Montpelier"];
    }

    // Return the address of the new object
    return self;
}

- (IBAction)showQuestion:(id)sender
{
    // Step to the next question
    self.currentQuestionIndex++;

    // Am I pass the last question?
    if (self.currentQuestionIndex == [self.questions count]) {
        // Go back to the first question
        self.currentQuestionIndex = 0;
    }

    // Get the string at that index in the questions array
    NSString *question = self.questions[self.currentQuestionIndex];

    // Display the string in the question label
    [self animateLabel:self.questionLabel withText:question];

    // Reset the answer label
    if (![self.answerLabel.text isEqualToString:@"???"]) {
        [self animateLabel:self.answerLabel withText:@"???"];
    }
}

- (IBAction)showAnswer:(id)sender
{
    // What is the answer to the current question?
    NSString *answer = self.answers[self.currentQuestionIndex];

    // Display it in the answer label
    [self animateLabel:self.answerLabel withText:answer];
}

- (void)animateLabel:(UILabel *)label withText:(NSString *)text
{
    CGRect currentRect = label.frame;

    CGRect leftRect = currentRect;
    leftRect.origin.x = 0 - currentRect.size.width;

    CGRect rightRect = currentRect;
    rightRect.origin.x = [[UIScreen mainScreen] bounds].size.width;

    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         label.frame = rightRect;
                         label.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         label.text = text;
                         label.frame = leftRect;

                         [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              label.frame = currentRect;
                                              label.alpha = 1.0;
                                          } completion:NULL];
                     }];
}

@end
